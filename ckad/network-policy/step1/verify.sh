#!/bin/bash
# verify.sh - NetworkPolicy Pod Label Configuration Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

log "INFO" "Running NetworkPolicy Label Validations..."
echo "" | tee -a "$OUTPUT_FILE"

NS="golden-hawk"

# Pre-check: NetworkPolicies still exist and are unmodified
check_k8s_resource networkpolicy "default-deny" "$NS" "" "" ""
check_k8s_resource networkpolicy "allow-front-db" "$NS" "" "" ""

# Verify policies were not tampered with (selectors intact)
check_k8s_resource networkpolicy "default-deny" "$NS" "" '{.spec.podSelector.matchLabels.role}' "restricted"
check_k8s_resource networkpolicy "allow-front-db" "$NS" "" '{.spec.podSelector.matchLabels.role}' "restricted"

# Task 2: backend pods have role=restricted label
# Check the Deployment template labels (persists across restarts)
BACKEND_TMPL_ROLE=$(kubectl get deployment backend -n "$NS" -o jsonpath='{.spec.template.metadata.labels.role}' 2>/dev/null)
if [ "$BACKEND_TMPL_ROLE" == "restricted" ]; then
  log "PASS" "Deployment backend pod template has label role=restricted"
  ((PASS_COUNT++))
else
  log "FAIL" "Deployment backend pod template missing label role=restricted (found: '$BACKEND_TMPL_ROLE')"
  ((FAIL_COUNT++))
fi

# Also verify the running pod has the label
BACKEND_POD=$(kubectl get pods -n "$NS" -l app=backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$BACKEND_POD" ]; then
  BACKEND_POD_ROLE=$(kubectl get pod "$BACKEND_POD" -n "$NS" -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
  if [ "$BACKEND_POD_ROLE" == "restricted" ]; then
    log "PASS" "Running backend pod has label role=restricted"
    ((PASS_COUNT++))
  else
    log "FAIL" "Running backend pod missing label role=restricted (found: '$BACKEND_POD_ROLE')"
    ((FAIL_COUNT++))
  fi
else
  log "FAIL" "No backend pod found with label app=backend"
  ((FAIL_COUNT++))
fi

# Task 3: front pods have name=front label
FRONT_TMPL_NAME=$(kubectl get deployment front -n "$NS" -o jsonpath='{.spec.template.metadata.labels.name}' 2>/dev/null)
if [ "$FRONT_TMPL_NAME" == "front" ]; then
  log "PASS" "Deployment front pod template has label name=front"
  ((PASS_COUNT++))
else
  log "FAIL" "Deployment front pod template missing label name=front (found: '$FRONT_TMPL_NAME')"
  ((FAIL_COUNT++))
fi

FRONT_POD=$(kubectl get pods -n "$NS" -l app=front -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$FRONT_POD" ]; then
  FRONT_POD_NAME=$(kubectl get pod "$FRONT_POD" -n "$NS" -o jsonpath='{.metadata.labels.name}' 2>/dev/null)
  if [ "$FRONT_POD_NAME" == "front" ]; then
    log "PASS" "Running front pod has label name=front"
    ((PASS_COUNT++))
  else
    log "FAIL" "Running front pod missing label name=front (found: '$FRONT_POD_NAME')"
    ((FAIL_COUNT++))
  fi
else
  log "FAIL" "No front pod found with label app=front"
  ((FAIL_COUNT++))
fi

# Task 4: db pods have name=db label
DB_TMPL_NAME=$(kubectl get deployment db -n "$NS" -o jsonpath='{.spec.template.metadata.labels.name}' 2>/dev/null)
if [ "$DB_TMPL_NAME" == "db" ]; then
  log "PASS" "Deployment db pod template has label name=db"
  ((PASS_COUNT++))
else
  log "FAIL" "Deployment db pod template missing label name=db (found: '$DB_TMPL_NAME')"
  ((FAIL_COUNT++))
fi

DB_POD=$(kubectl get pods -n "$NS" -l app=db -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$DB_POD" ]; then
  DB_POD_NAME=$(kubectl get pod "$DB_POD" -n "$NS" -o jsonpath='{.metadata.labels.name}' 2>/dev/null)
  if [ "$DB_POD_NAME" == "db" ]; then
    log "PASS" "Running db pod has label name=db"
    ((PASS_COUNT++))
  else
    log "FAIL" "Running db pod missing label name=db (found: '$DB_POD_NAME')"
    ((FAIL_COUNT++))
  fi
else
  log "FAIL" "No db pod found with label app=db"
  ((FAIL_COUNT++))
fi

# Connectivity test: backend -> front (should work)
if [ -n "$BACKEND_POD" ] && [ -n "$FRONT_POD" ]; then
  FRONT_IP=$(kubectl get pod "$FRONT_POD" -n "$NS" -o jsonpath='{.status.podIP}' 2>/dev/null)
  if [ -n "$FRONT_IP" ]; then
    if kubectl exec -n "$NS" "$BACKEND_POD" -- wget -qO- --timeout=3 "http://${FRONT_IP}:80" >/dev/null 2>&1; then
      log "PASS" "backend can reach front (HTTP)"
      ((PASS_COUNT++))
    else
      log "FAIL" "backend cannot reach front — labels may be incorrect"
      ((FAIL_COUNT++))
    fi
  fi
fi

print_summary_and_exit
