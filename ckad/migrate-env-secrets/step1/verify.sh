#!/bin/bash
# verify.sh - Migrate Environment Variables to Secrets Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

log "INFO" "Running Secret Migration Validations..."
echo "" | tee -a "$OUTPUT_FILE"

NS="production"

# Task 1: Secret exists
check_k8s_resource secret "database-secret" "$NS" "" "" ""

# Task 1a: Secret key - username
check_k8s_resource secret "database-secret" "$NS" "" '{.data.username}' "$(echo -n 'postgres-admin' | base64)"

# Task 1b: Secret key - password
check_k8s_resource secret "database-secret" "$NS" "" '{.data.password}' "$(echo -n 'S3cur3P@ss!' | base64)"

# Task 1c: Secret key - dbname
check_k8s_resource secret "database-secret" "$NS" "" '{.data.dbname}' "$(echo -n 'app_production' | base64)"

# Task 2: Deployment still exists
check_k8s_resource deployment "webapp" "$NS" "" "" ""

# Task 2a: DB_USER uses secretKeyRef
DB_USER_REF=$(kubectl get deployment webapp -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DB_USER")].valueFrom.secretKeyRef.name}' 2>/dev/null)
DB_USER_KEY=$(kubectl get deployment webapp -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DB_USER")].valueFrom.secretKeyRef.key}' 2>/dev/null)
if [ "$DB_USER_REF" == "database-secret" ] && [ "$DB_USER_KEY" == "username" ]; then
  log "PASS" "DB_USER references database-secret.username via secretKeyRef"
  ((PASS_COUNT++))
else
  log "FAIL" "DB_USER does not reference database-secret.username (secret: '$DB_USER_REF', key: '$DB_USER_KEY')"
  ((FAIL_COUNT++))
fi

# Task 2b: DB_PASS uses secretKeyRef
DB_PASS_REF=$(kubectl get deployment webapp -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DB_PASS")].valueFrom.secretKeyRef.name}' 2>/dev/null)
DB_PASS_KEY=$(kubectl get deployment webapp -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DB_PASS")].valueFrom.secretKeyRef.key}' 2>/dev/null)
if [ "$DB_PASS_REF" == "database-secret" ] && [ "$DB_PASS_KEY" == "password" ]; then
  log "PASS" "DB_PASS references database-secret.password via secretKeyRef"
  ((PASS_COUNT++))
else
  log "FAIL" "DB_PASS does not reference database-secret.password (secret: '$DB_PASS_REF', key: '$DB_PASS_KEY')"
  ((FAIL_COUNT++))
fi

# Task 2c: DB_NAME uses secretKeyRef
DB_NAME_REF=$(kubectl get deployment webapp -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DB_NAME")].valueFrom.secretKeyRef.name}' 2>/dev/null)
DB_NAME_KEY=$(kubectl get deployment webapp -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DB_NAME")].valueFrom.secretKeyRef.key}' 2>/dev/null)
if [ "$DB_NAME_REF" == "database-secret" ] && [ "$DB_NAME_KEY" == "dbname" ]; then
  log "PASS" "DB_NAME references database-secret.dbname via secretKeyRef"
  ((PASS_COUNT++))
else
  log "FAIL" "DB_NAME does not reference database-secret.dbname (secret: '$DB_NAME_REF', key: '$DB_NAME_KEY')"
  ((FAIL_COUNT++))
fi

# Task 2d: Ensure hardcoded values are removed (no plain 'value' field on DB_USER/DB_PASS/DB_NAME)
HARDCODED=false
for ENV_NAME in DB_USER DB_PASS DB_NAME; do
  PLAIN_VAL=$(kubectl get deployment webapp -n "$NS" -o jsonpath="{.spec.template.spec.containers[0].env[?(@.name==\"$ENV_NAME\")].value}" 2>/dev/null)
  if [ -n "$PLAIN_VAL" ]; then
    HARDCODED=true
    log "FAIL" "$ENV_NAME still has a hardcoded value: '$PLAIN_VAL'"
    ((FAIL_COUNT++))
  fi
done
if [ "$HARDCODED" = false ]; then
  log "PASS" "No hardcoded values remain for DB_USER, DB_PASS, DB_NAME"
  ((PASS_COUNT++))
fi

# Task 3: Deployment rollout
wait_and_check_rollout deployment "webapp" "$NS" "30s"

print_summary_and_exit
