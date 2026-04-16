#!/bin/bash
# verify.sh - CKA Lab 16: NodePort Service
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

NAMESPACE="relative"
SVC_NAME="nodeport-service"
DEPLOY_NAME="nodeport-deployment"
EXPECTED_NODEPORT="30080"

log "INFO" "Running NodePort Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# 1. Configure the deployment `nodeport-deployment`
log "INFO" "Checking Deployment Configuration..."
check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE" "" "{.spec.template.spec.containers[0].ports[0].containerPort}" "80"
check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE" "" "{.spec.template.spec.containers[0].ports[0].name}" "http"
check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE" "" "{.spec.template.spec.containers[0].ports[0].protocol}" "TCP"

# 2. Create a NodePort Service named `nodeport-service`
log "INFO" "Checking Service Configuration..."
check_k8s_resource svc "$SVC_NAME" "$NAMESPACE" "" "{.spec.type}" "NodePort"
check_k8s_resource svc "$SVC_NAME" "$NAMESPACE" "" "{.spec.ports[0].port}" "80"
check_k8s_resource svc "$SVC_NAME" "$NAMESPACE" "" "{.spec.ports[0].protocol}" "TCP"
check_k8s_resource svc "$SVC_NAME" "$NAMESPACE" "" "{.spec.ports[0].nodePort}" "$EXPECTED_NODEPORT"

# 3. Integration Test: Verify End-to-End reachability
log "INFO" "Verifying Service Reachability..."
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
if [ -n "$NODE_IP" ]; then
    check_http_status "http://${NODE_IP}:${EXPECTED_NODEPORT}" "200" 5 2
else
    log "FAIL" "Could not resolve Node IP for reachability test."
    ((FAIL_COUNT++))
fi

print_summary_and_exit