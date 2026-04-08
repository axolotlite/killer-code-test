#!/bin/bash
# verify.sh - CKA Lab 16: NodePort Service
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

# 1. Source the utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/utility.sh" ]; then
  source "$SCRIPT_DIR/utility.sh"
else
  exit 1
fi

# 2. Define target parameters
NAMESPACE="relative"
SVC_NAME="nodeport-service"
DEPLOY_NAME="nodeport-deployment"
EXPECTED_NODEPORT="30080"

# ==========================================
# EXECUTION BLOCK
# ==========================================

log "INFO" "Running CKA Lab 16: NodePort Service Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# --- Task 2: Verify NodePort Service ---
if ! kubectl get svc "$SVC_NAME" -n "$NAMESPACE" &>/dev/null; then
    log "FAIL" "Service '$SVC_NAME' does not exist in namespace '$NAMESPACE'."
    ((FAIL_COUNT++))
    print_summary_and_exit
fi

check_k8s_resource svc "$SVC_NAME" "$NAMESPACE" "" "{.spec.type}" "NodePort"
check_k8s_resource svc "$SVC_NAME" "$NAMESPACE" "" "{.spec.ports[0].nodePort}" "$EXPECTED_NODEPORT"
check_k8s_resource svc "$SVC_NAME" "$NAMESPACE" "" "{.spec.ports[0].port}" "80"
check_k8s_resource svc "$SVC_NAME" "$NAMESPACE" "" "{.spec.ports[0].protocol}" "TCP"

# --- Task 1: Verify Deployment Configuration ---
if ! kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" &>/dev/null; then
    log "FAIL" "Deployment '$DEPLOY_NAME' does not exist in namespace '$NAMESPACE'."
    ((FAIL_COUNT++))
    print_summary_and_exit
fi

# We use simple index-based paths to avoid fragile JSONPath filters
check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE" "" "{.spec.template.spec.containers[0].ports[0].containerPort}" "80"
check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE" "" "{.spec.template.spec.containers[0].ports[0].name}" "http"
check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE" "" "{.spec.template.spec.containers[0].ports[0].protocol}" "TCP"

# --- Task 3: Ground Truth Connectivity Check ---
log "INFO" "Performing live reachability test via NodePort..."

NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
URL="http://${NODE_IP}:${EXPECTED_NODEPORT}"

# Wait up to 20 seconds for endpoints to be ready
HTTP_CODE="000"
for i in {1..10}; do
    # Get just the status code. '|| true' prevents script from exiting on curl error
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 "$URL" || true)
    # Clean up any potential concatenated output (e.g., "000000")
    HTTP_CODE=$(echo "$HTTP_CODE" | grep -oE '[0-9]{3}' | head -n 1)
    
    if [ "$HTTP_CODE" == "200" ]; then
        break
    fi
    sleep 2
done

if [ "$HTTP_CODE" == "200" ]; then
    log "PASS" "Service is reachable! Successfully received HTTP 200 from $URL."
    ((PASS_COUNT++))
else
    log "FAIL" "Failed to reach service at $URL. Received HTTP code: ${HTTP_CODE:-000}."
    ((FAIL_COUNT++))
fi

# ==========================================
# RESULTS SUMMARY
# ==========================================
print_summary_and_exit