#!/bin/bash
# verify.sh - NetworkPolicy Cross-Namespace Label Configuration Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

log "INFO" "Running NetworkPolicy Cross-Namespace Label Validations..."
echo "" | tee -a "$OUTPUT_FILE"

NS_BACKEND="golden-hawk"
NS_FRONT="frontend"
NS_DB="database"

# Pre-check: NetworkPolicies still exist and are unmodified
check_k8s_resource networkpolicy "default-deny" "$NS_BACKEND" "" "" ""
check_k8s_resource networkpolicy "allow-front-db" "$NS_BACKEND" "" "" ""
check_k8s_resource networkpolicy "default-deny" "$NS_BACKEND" "" '{.spec.podSelector.matchLabels.role}' "restricted"
check_k8s_resource networkpolicy "allow-front-db" "$NS_BACKEND" "" '{.spec.podSelector.matchLabels.role}' "restricted"

# Task 2: backend deployment has role=restricted in pod template
BACKEND_TMPL_ROLE=$(kubectl get deployment backend -n "$NS_BACKEND" -o jsonpath='{.spec.template.metadata.labels.role}' 2>/dev/null)
if [ "$BACKEND_TMPL_ROLE" == "restricted" ]; then
  log "PASS" "Deployment backend (golden-hawk) pod template has label role=restricted"
  ((PASS_COUNT++))
else
  log "FAIL" "Deployment backend (golden-hawk) pod template missing label role=restricted (found: '$BACKEND_TMPL_ROLE')"
  ((FAIL_COUNT++))
fi

BACKEND_POD=$(kubectl get pods -n "$NS_BACKEND" -l app=backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$BACKEND_POD" ]; then
  BACKEND_POD_ROLE=$(kubectl get pod "$BACKEND_POD" -n "$NS_BACKEND" -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
  if [ "$BACKEND_POD_ROLE" == "restricted" ]; then
    log "PASS" "Running backend pod has label role=restricted"
    ((PASS_COUNT++))
  else
    log "FAIL" "Running backend pod missing label role=restricted (found: '$BACKEND_POD_ROLE')"
    ((FAIL_COUNT++))
  fi
else
  log "FAIL" "No backend pod found with label app=backend in $NS_BACKEND"
  ((FAIL_COUNT++))
fi

# Task 3: frontend namespace has tier=frontend label
FRONT_NS_TIER=$(kubectl get namespace "$NS_FRONT" -o jsonpath='{.metadata.labels.tier}' 2>/dev/null)
if [ "$FRONT_NS_TIER" == "frontend" ]; then
  log "PASS" "Namespace $NS_FRONT has label tier=frontend"
  ((PASS_COUNT++))
else
  log "FAIL" "Namespace $NS_FRONT missing label tier=frontend (found: '$FRONT_NS_TIER')"
  ((FAIL_COUNT++))
fi

# Task 4: front deployment (in frontend ns) has name=front in pod template
FRONT_TMPL_NAME=$(kubectl get deployment front -n "$NS_FRONT" -o jsonpath='{.spec.template.metadata.labels.name}' 2>/dev/null)
if [ "$FRONT_TMPL_NAME" == "front" ]; then
  log "PASS" "Deployment front ($NS_FRONT) pod template has label name=front"
  ((PASS_COUNT++))
else
  log "FAIL" "Deployment front ($NS_FRONT) pod template missing label name=front (found: '$FRONT_TMPL_NAME')"
  ((FAIL_COUNT++))
fi

FRONT_POD=$(kubectl get pods -n "$NS_FRONT" -l app=front -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$FRONT_POD" ]; then
  FRONT_POD_NAME=$(kubectl get pod "$FRONT_POD" -n "$NS_FRONT" -o jsonpath='{.metadata.labels.name}' 2>/dev/null)
  if [ "$FRONT_POD_NAME" == "front" ]; then
    log "PASS" "Running front pod has label name=front"
    ((PASS_COUNT++))
  else
    log "FAIL" "Running front pod missing label name=front (found: '$FRONT_POD_NAME')"
    ((FAIL_COUNT++))
  fi
else
  log "FAIL" "No front pod found with label app=front in $NS_FRONT"
  ((FAIL_COUNT++))
fi

# Task 5: database namespace has tier=database label
DB_NS_TIER=$(kubectl get namespace "$NS_DB" -o jsonpath='{.metadata.labels.tier}' 2>/dev/null)
if [ "$DB_NS_TIER" == "database" ]; then
  log "PASS" "Namespace $NS_DB has label tier=database"
  ((PASS_COUNT++))
else
  log "FAIL" "Namespace $NS_DB missing label tier=database (found: '$DB_NS_TIER')"
  ((FAIL_COUNT++))
fi

# Task 6: db deployment (in database ns) has name=db in pod template
DB_TMPL_NAME=$(kubectl get deployment db -n "$NS_DB" -o jsonpath='{.spec.template.metadata.labels.name}' 2>/dev/null)
if [ "$DB_TMPL_NAME" == "db" ]; then
  log "PASS" "Deployment db ($NS_DB) pod template has label name=db"
  ((PASS_COUNT++))
else
  log "FAIL" "Deployment db ($NS_DB) pod template missing label name=db (found: '$DB_TMPL_NAME')"
  ((FAIL_COUNT++))
fi

DB_POD=$(kubectl get pods -n "$NS_DB" -l app=db -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$DB_POD" ]; then
  DB_POD_NAME=$(kubectl get pod "$DB_POD" -n "$NS_DB" -o jsonpath='{.metadata.labels.name}' 2>/dev/null)
  if [ "$DB_POD_NAME" == "db" ]; then
    log "PASS" "Running db pod has label name=db"
    ((PASS_COUNT++))
  else
    log "FAIL" "Running db pod missing label name=db (found: '$DB_POD_NAME')"
    ((FAIL_COUNT++))
  fi
else
  log "FAIL" "No db pod found with label app=db in $NS_DB"
  ((FAIL_COUNT++))
fi

# Connectivity test: backend -> front across namespaces (should work after labeling)
if [ -n "$BACKEND_POD" ] && [ -n "$FRONT_POD" ]; then
  FRONT_IP=$(kubectl get pod "$FRONT_POD" -n "$NS_FRONT" -o jsonpath='{.status.podIP}' 2>/dev/null)
  if [ -n "$FRONT_IP" ]; then
    if kubectl exec -n "$NS_BACKEND" "$BACKEND_POD" -- wget -qO- --timeout=3 "http://${FRONT_IP}:80" >/dev/null 2>&1; then
      log "PASS" "backend (golden-hawk) can reach front (frontend) cross-namespace"
      ((PASS_COUNT++))
    else
      log "FAIL" "backend cannot reach front cross-namespace — labels may be incorrect"
      ((FAIL_COUNT++))
    fi
  fi
fi

print_summary_and_exit
