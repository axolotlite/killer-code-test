#!/bin/bash
# verify.sh - CKA Lab 05: Horizontal Pod Autoscaler (HPA)
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

HPA_NAME="apache-server"
NAMESPACE="autoscale"

log "INFO" "Running HPA Validations..."
echo "" | tee -a "$OUTPUT_FILE"

check_k8s_resource hpa "$HPA_NAME" "$NAMESPACE" "" "{.spec.scaleTargetRef.kind}" "Deployment"
check_k8s_resource hpa "$HPA_NAME" "$NAMESPACE" "" "{.spec.scaleTargetRef.name}" "apache-deployment"
check_k8s_resource hpa "$HPA_NAME" "$NAMESPACE" "" "{.spec.minReplicas}" "1"
check_k8s_resource hpa "$HPA_NAME" "$NAMESPACE" "" "{.spec.maxReplicas}" "4"
check_k8s_resource hpa "$HPA_NAME" "$NAMESPACE" "" "{.spec.behavior.scaleDown.stabilizationWindowSeconds}" "30"

cpu_target=$(kubectl get hpa "$HPA_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.metrics[?(@.resource.name=="cpu")].resource.target.averageUtilization}' 2>/dev/null)
if [ "$cpu_target" == "50" ]; then
    log "PASS" "HPA '$HPA_NAME' correctly targets 50% CPU utilization"
    ((PASS_COUNT++))
else
    log "FAIL" "HPA CPU target is '${cpu_target:-Missing}', expected '50'"
    ((FAIL_COUNT++))
fi

print_summary_and_exit