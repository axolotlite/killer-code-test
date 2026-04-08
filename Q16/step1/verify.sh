#!/bin/bash
# verify.sh - CKA Lab 16: NodePort Service
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
NAMESPACE="default"
SVC_NAME="nodeport-service"
EXPECTED_SVC_TYPE="NodePort"
EXPECTED_NODEPORT="30080"
EXPECTED_SVC_PORT="80"
EXPECTED_PORT_NAME="http"
EXPECTED_CONTAINER_PORT="80"
EXPECTED_PROTOCOL="TCP"

# ==========================================
# EXECUTION BLOCK
# ==========================================

log "INFO" "Running CKA Lab 16: NodePort Service Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# --- Task 2: Verify NodePort Service ---

# 2.1 Check if the Service exists
if ! kubectl get svc "$SVC_NAME" -n "$NAMESPACE" &>/dev/null; then
    log "FAIL" "Service '$SVC_NAME' does not exist."
    ((FAIL_COUNT++))
    print_summary_and_exit
fi
log "PASS" "Service '$SVC_NAME' exists."
((PASS_COUNT++))

# 2.2 Check Service properties
check_k8s_resource svc "$SVC_NAME" "$NAMESPACE" "" "{.spec.type}" "$EXPECTED_SVC_TYPE"
check_k8s_resource svc "$SVC_NAME" "$NAMESPACE" "" "{.spec.ports[0].nodePort}" "$EXPECTED_NODEPORT"
check_k8s_resource svc "$SVC_NAME" "$NAMESPACE" "" "{.spec.ports[0].port}" "$EXPECTED_SVC_PORT"
check_k8s_resource svc "$SVC_NAME" "$NAMESPACE" "" "{.spec.ports[0].protocol}" "$EXPECTED_PROTOCOL"

# --- Verify the link between Service and Deployment ---

# 3.1 Get the selector from the service
SVC_SELECTOR_LABELS=$(kubectl get svc "$SVC_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.selector}' | tr -d '{}' | sed 's/:/=/g' | sed 's/"//g' | sed 's/,/,/g')
if [ -z "$SVC_SELECTOR_LABELS" ]; then
    log "FAIL" "Service '$SVC_NAME' does not have a selector defined."
    ((FAIL_COUNT++))
    print_summary_and_exit
fi

log "PASS" "Service '$SVC_NAME' has a selector defined: '$SVC_SELECTOR_LABELS'"
((PASS_COUNT++))

# 3.2 Find the deployment managed by this service
DEPLOY_NAME=$(kubectl get deploy -n "$NAMESPACE" -l "$SVC_SELECTOR_LABELS" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -z "$DEPLOY_NAME" ]; then
    log "FAIL" "Could not find any Deployment matching the service selector '$SVC_SELECTOR_LABELS'."
    ((FAIL_COUNT++))
    print_summary_and_exit
fi
log "PASS" "Found Deployment '$DEPLOY_NAME' matching the service selector."
((PASS_COUNT++))

# --- Task 1: Verify Deployment Container Port Configuration ---
log "INFO" "Checking container port configuration on Deployment '$DEPLOY_NAME'..."

# Find the specific port named 'http'
PORT_PATH="{.spec.template.spec.containers[0].ports[?(@.name=='$EXPECTED_PORT_NAME')]}"

check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE" "" "${PORT_PATH}.name" "$EXPECTED_PORT_NAME"
check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE" "" "${PORT_PATH}.containerPort" "$EXPECTED_CONTAINER_PORT"

# 3.3 Verify Service targetPort is correctly mapped
SVC_TARGET_PORT=$(kubectl get svc "$SVC_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].targetPort}')
if [[ "$SVC_TARGET_PORT" == "$EXPECTED_PORT_NAME" || "$SVC_TARGET_PORT" == "$EXPECTED_CONTAINER_PORT" ]]; then
    log "PASS" "Service targetPort '$SVC_TARGET_PORT' correctly targets the container port."
    ((PASS_COUNT++))
else
    log "FAIL" "Service targetPort is '$SVC_TARGET_PORT', but should be '$EXPECTED_PORT_NAME' or '$EXPECTED_CONTAINER_PORT'."
    ((FAIL_COUNT++))
fi

# --- Final Check: Live Reachability Test ---
log "INFO" "Performing live reachability test via NodePort..."

# 4.1 Get a Node IP
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
if [ -z "$NODE_IP" ]; then
    log "WARN" "Could not find Node InternalIP, falling back to Hostname. This might fail with DNS."
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="Hostname")].address}')
fi

if [ -z "$NODE_IP" ]; then
    log "FAIL" "Could not determine any Node IP or Hostname to test the NodePort service."
    ((FAIL_COUNT++))
else
    URL="http://${NODE_IP}:${EXPECTED_NODEPORT}"
    log "INFO" "Testing URL: $URL (waiting for HTTP 200)..."
    HTTP_CODE="000"
    for i in {1..5}; do
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 4 "$URL" || echo "000")
        if [ "$HTTP_CODE" == "200" ]; then
            break
        fi
        sleep 2
    done

    if [ "$HTTP_CODE" == "200" ]; then
        log "PASS" "Service is reachable! Successfully received HTTP 200 from $URL."
        ((PASS_COUNT++))
    else
        log "FAIL" "Failed to get HTTP 200 from $URL. Received code: $HTTP_CODE. Ensure the backend application is running and serving on port 80."
        ((FAIL_COUNT++))
    fi
fi

# ==========================================
# RESULTS SUMMARY
# ==========================================
print_summary_and_exit