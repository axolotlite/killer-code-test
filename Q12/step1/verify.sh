#!/bin/bash
# verify.sh - CKA Lab 12: Ingress Configuration
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

# 1. Source the utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/utility.sh" ]; then
  source "$SCRIPT_DIR/utility.sh"
else
  echo "[FATAL] utility.sh not found in $SCRIPT_DIR" | tee -a "$OUTPUT_FILE"
  exit 1
fi

# 2. Define target parameters
NAMESPACE="echo-app"
SVC_NAME="echo-service"
EXPECTED_SVC_TYPE="NodePort"
EXPECTED_NODEPORT="31284"

INGRESS_NAME="echo"
EXPECTED_HOST="echo-service.org"
EXPECTED_PATH="/echo"
EXPECTED_PATHTYPE="Prefix"

# ==========================================
# EXECUTION BLOCK
# ==========================================

log "INFO" "Running CKA Lab 12: Ingress Configuration Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# --- Task 1: Verify NodePort Service ---

# 1.1 Verify the Service exists
if ! kubectl get svc "$SVC_NAME" -n "$NAMESPACE" &>/dev/null; then
    log "FAIL" "Service '$SVC_NAME' does not exist in namespace '$NAMESPACE'."
    ((FAIL_COUNT++))
else
    log "PASS" "Service '$SVC_NAME' exists in namespace '$NAMESPACE'."
    ((PASS_COUNT++))
    
    # 1.2 Verify the Service Type is NodePort
    check_k8s_resource svc "$SVC_NAME" "$NAMESPACE" "" "{.spec.type}" "$EXPECTED_SVC_TYPE"

    # 1.3 Verify the NodePort value
    ACTUAL_NODEPORT=$(kubectl get svc "$SVC_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].nodePort}')
    
    if [ "$ACTUAL_NODEPORT" == "$EXPECTED_NODEPORT" ]; then
        log "PASS" "Service '$SVC_NAME' NodePort is correctly set to $EXPECTED_NODEPORT."
        ((PASS_COUNT++))
    else
        log "FAIL" "Service '$SVC_NAME' NodePort mismatch. Expected: $EXPECTED_NODEPORT, Found: $ACTUAL_NODEPORT"
        ((FAIL_COUNT++))
    fi
fi
# --- Task 2: Verify Ingress Configuration ---

# 2.1 Verify the Ingress exists
if ! kubectl get ingress "$INGRESS_NAME" -n "$NAMESPACE" &>/dev/null; then
    log "FAIL" "Ingress '$INGRESS_NAME' does not exist in namespace '$NAMESPACE'. Halting Ingress checks."
    ((FAIL_COUNT++))
    print_summary_and_exit
else
    log "PASS" "Ingress '$INGRESS_NAME' exists in namespace '$NAMESPACE'."
    ((PASS_COUNT++))
fi

# 2.2 Verify Ingress Host Configuration
check_k8s_resource ingress "$INGRESS_NAME" "$NAMESPACE" "" "{.spec.rules[0].host}" "$EXPECTED_HOST"

# 2.3 Verify Ingress Path
check_k8s_resource ingress "$INGRESS_NAME" "$NAMESPACE" "" "{.spec.rules[0].http.paths[0].path}" "$EXPECTED_PATH"

# 2.4 Verify Ingress PathType
check_k8s_resource ingress "$INGRESS_NAME" "$NAMESPACE" "" "{.spec.rules[0].http.paths[0].pathType}" "$EXPECTED_PATHTYPE"

# 2.5 Verify Ingress Backend routes to the correct Service
check_k8s_resource ingress "$INGRESS_NAME" "$NAMESPACE" "" "{.spec.rules[0].http.paths[0].backend.service.name}" "$SVC_NAME"

# --- Task 3: Accessibility Note ---
log "INFO" "Note: Task 3 (curl http://echo-service.org/echo) requires an active Ingress Controller and correct DNS/local host mapping."
log "INFO" "If all above checks PASS, the Kubernetes resource configurations are correct."

# ==========================================
# RESULTS SUMMARY
# ==========================================

print_summary_and_exit