#!/bin/bash
# verify.sh - CKA Lab 07: PriorityClass
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

# 1. Source the utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/utility.sh" ]; then
  source "$SCRIPT_DIR/utility.sh"
else
  echo "[FATAL] utility.sh not found in $SCRIPT_DIR" | tee -a "$OUTPUT_FILE"
  exit 1
fi

# 2. Define expected state
PC_NAME="high-priority"
BASE_PC_NAME="user-critical"
DEPLOY_NAME="busybox-logger"
NAMESPACE="priority"

# ==========================================
# EXECUTION BLOCK
# ==========================================

log "INFO" "Running CKA Lab 07: PriorityClass Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# 1. Get the value of the existing 'user-critical' PriorityClass
base_value=$(kubectl get priorityclass "$BASE_PC_NAME" -o jsonpath='{.value}' 2>/dev/null)

if [ -z "$base_value" ]; then
    log "FAIL" "Base PriorityClass '$BASE_PC_NAME' not found. Is the lab environment set up correctly?"
    ((FAIL_COUNT++))
    print_summary_and_exit
fi

# Calculate the expected value (one less than user-critical)
expected_value=$((base_value - 1))

log "INFO" "Existing PriorityClass '$BASE_PC_NAME' has value: $base_value"
log "INFO" "Expected value for '$PC_NAME' should be: $expected_value"
echo "" | tee -a "$OUTPUT_FILE"

# 2. Verify the new PriorityClass Exists
check_k8s_resource priorityclass "$PC_NAME" "" "" "" ""

if ! kubectl get priorityclass "$PC_NAME" &>/dev/null; then
    log "FAIL" "PriorityClass '$PC_NAME' does not exist. Halting further checks."
    ((FAIL_COUNT++))
    print_summary_and_exit
fi

# 3. Verify PriorityClass Value against the calculated value
check_k8s_resource priorityclass "$PC_NAME" "" "" "{.value}" "$expected_value"

# 4. Verify Target Deployment Exists
check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE" "" "" ""

if ! kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" &>/dev/null; then
    log "FAIL" "Deployment '$DEPLOY_NAME' does not exist in namespace '$NAMESPACE'. Halting further checks."
    ((FAIL_COUNT++))
    print_summary_and_exit
fi

# 5. Verify the PriorityClass is actively attached to the deployment pods
check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE" "" "{.spec.template.spec.priorityClassName}" "$PC_NAME"

# ==========================================
# RESULTS SUMMARY
# ==========================================

print_summary_and_exit