#!/bin/bash
# verify.sh - CKA Lab 05: Horizontal Pod Autoscaler (HPA)
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
HPA_NAME="apache-server"
NAMESPACE="autoscale"
TARGET_KIND="Deployment"
TARGET_NAME="apache-deployment"
EXPECTED_MIN="1"
EXPECTED_MAX="4"
EXPECTED_CPU="50"
EXPECTED_STABILIZATION="30"

# ==========================================
# EXECUTION BLOCK
# ==========================================

log "INFO" "Running CKA Lab 05: HPA Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# 1. Verify HPA existence
check_k8s_resource hpa "$HPA_NAME" "$NAMESPACE" "" "" ""

# Halt further checks if HPA doesn't exist
if ! kubectl get hpa "$HPA_NAME" -n "$NAMESPACE" &>/dev/null; then
    log "FAIL" "HPA '$HPA_NAME' does not exist in namespace '$NAMESPACE'. Halting further checks."
    ((FAIL_COUNT++))
    print_summary_and_exit
fi

# 2. Verify Target Resource Kind
check_k8s_resource hpa "$HPA_NAME" "$NAMESPACE" "" "{.spec.scaleTargetRef.kind}" "$TARGET_KIND"

# 3. Verify Target Resource Name
check_k8s_resource hpa "$HPA_NAME" "$NAMESPACE" "" "{.spec.scaleTargetRef.name}" "$TARGET_NAME"

# 4. Verify Minimum Replicas
check_k8s_resource hpa "$HPA_NAME" "$NAMESPACE" "" "{.spec.minReplicas}" "$EXPECTED_MIN"

# 5. Verify Maximum Replicas
check_k8s_resource hpa "$HPA_NAME" "$NAMESPACE" "" "{.spec.maxReplicas}" "$EXPECTED_MAX"

# 6. Verify Downscale Stabilization Window
# (This is located under behavior.scaleDown.stabilizationWindowSeconds in autoscaling/v2)
check_k8s_resource hpa "$HPA_NAME" "$NAMESPACE" "" "{.spec.behavior.scaleDown.stabilizationWindowSeconds}" "$EXPECTED_STABILIZATION"

# 7. Verify CPU Target (Custom Array Check)
# Kubernetes auto-converts v1/v2 definitions, but always presents them as an array in autoscaling/v2 API
cpu_target=$(kubectl get hpa "$HPA_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.metrics[?(@.resource.name=="cpu")].resource.target.averageUtilization}' 2>/dev/null)

if [ "$cpu_target" == "$EXPECTED_CPU" ]; then
    log "PASS" "HPA '$HPA_NAME' correctly targets $EXPECTED_CPU% CPU utilization"
    ((PASS_COUNT++))
else
    log "FAIL" "HPA '$HPA_NAME' CPU target is '${cpu_target:-Missing}', expected '$EXPECTED_CPU'"
    ((FAIL_COUNT++))
fi

# ==========================================
# RESULTS SUMMARY
# ==========================================

print_summary_and_exit