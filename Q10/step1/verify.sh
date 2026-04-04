#!/bin/bash
# verify.sh - CKA Lab 10: Taints and Tolerations
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
NODE_NAME="node01"
TAINT_KEY="PERMISSION"
TAINT_VALUE="granted"
TAINT_EFFECT="NoSchedule"

POD_NAME="nginx"
NAMESPACE="default"
EXPECTED_IMAGE="nginx:stable"

# ==========================================
# EXECUTION BLOCK
# ==========================================

log "INFO" "Running CKA Lab 10: Taints and Tolerations Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# 1. Verify Node Exists
if ! kubectl get node "$NODE_NAME" &>/dev/null; then
    log "FAIL" "Node '$NODE_NAME' does not exist in this cluster. Please verify the environment."
    ((FAIL_COUNT++))
    print_summary_and_exit
fi

# 2. Verify Node Taint (Custom Array Check)
taint_exists=$(kubectl get node "$NODE_NAME" -o jsonpath="{.spec.taints[?(@.key==\"$TAINT_KEY\")]}" 2>/dev/null)

if [ -n "$taint_exists" ]; then
    taint_val=$(kubectl get node "$NODE_NAME" -o jsonpath="{.spec.taints[?(@.key==\"$TAINT_KEY\")].value}" 2>/dev/null)
    taint_eff=$(kubectl get node "$NODE_NAME" -o jsonpath="{.spec.taints[?(@.key==\"$TAINT_KEY\")].effect}" 2>/dev/null)

    if [ "$taint_val" == "$TAINT_VALUE" ] && [ "$taint_eff" == "$TAINT_EFFECT" ]; then
        log "PASS" "Node '$NODE_NAME' has the correct taint ($TAINT_KEY=$TAINT_VALUE:$TAINT_EFFECT)"
        ((PASS_COUNT++))
    else
        log "FAIL" "Node '$NODE_NAME' taint is incorrect. Found value='$taint_val', effect='$taint_eff'. Expected '$TAINT_VALUE' and '$TAINT_EFFECT'."
        ((FAIL_COUNT++))
    fi
else
    log "FAIL" "Node '$NODE_NAME' does NOT have a taint with the key '$TAINT_KEY'"
    ((FAIL_COUNT++))
fi

# 3. Verify Pod Existence
check_k8s_resource pod "$POD_NAME" "$NAMESPACE" "" "" ""

# Halt further checks if Pod doesn't exist
if ! kubectl get pod "$POD_NAME" -n "$NAMESPACE" &>/dev/null; then
    log "FAIL" "Pod '$POD_NAME' does not exist. Halting further checks."
    ((FAIL_COUNT++))
    print_summary_and_exit
fi

# 4. Verify Pod Image (Custom Array Check)
actual_image=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath="{.spec.containers[0].image}" 2>/dev/null)
if [ "$actual_image" == "$EXPECTED_IMAGE" ]; then
    log "PASS" "Pod '$POD_NAME' uses the correct image: '$EXPECTED_IMAGE'"
    ((PASS_COUNT++))
else
    log "FAIL" "Pod '$POD_NAME' image is '${actual_image:-Missing}', expected '$EXPECTED_IMAGE'"
    ((FAIL_COUNT++))
fi

# 5. Verify Pod is Scheduled on 'node01'
# This uses the utility function to explicitly check the node assignment
check_k8s_resource pod "$POD_NAME" "$NAMESPACE" "" "{.spec.nodeName}" "$NODE_NAME"

# 6. Verify Pod is Running (Proof that the Toleration was successful)
# If the node has the taint, and the pod is running on the node, the scheduler implicitly proves the toleration is valid!
pod_phase=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath="{.status.phase}")
if [ "$pod_phase" == "Running" ]; then
    log "PASS" "Pod '$POD_NAME' is in the 'Running' phase on '$NODE_NAME' (Toleration successfully applied!)"
    ((PASS_COUNT++))
else
    log "FAIL" "Pod '$POD_NAME' is not Running (Current Phase: $pod_phase). Check if your toleration matches the taint exactly."
    ((FAIL_COUNT++))
fi

# ==========================================
# RESULTS SUMMARY
# ==========================================

print_summary_and_exit