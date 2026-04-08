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

INGRESS_NAME="echo"
EXPECTED_HOST="echo-service.org"
EXPECTED_PATH="/echo"
EXPECTED_PATHTYPE="Prefix"
URL="http://${EXPECTED_HOST}${EXPECTED_PATH}"

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
    print_summary_and_exit
else
    log "PASS" "Service '$SVC_NAME' exists in namespace '$NAMESPACE'."
    ((PASS_COUNT++))
    
    # 1.2 Verify the Service Type is NodePort
    check_k8s_resource svc "$SVC_NAME" "$NAMESPACE" "" "{.spec.type}" "$EXPECTED_SVC_TYPE"
fi

# --- Task 2: Verify Ingress Configuration ---

# 2.1 Verify the Ingress exists
if ! kubectl get ingress "$INGRESS_NAME" -n "$NAMESPACE" &>/dev/null; then
    log "FAIL" "Ingress '$INGRESS_NAME' does not exist in namespace '$NAMESPACE'. Halting further checks."
    ((FAIL_COUNT++))
    print_summary_and_exit
else
    log "PASS" "Ingress '$INGRESS_NAME' exists in namespace '$NAMESPACE'."
    ((PASS_COUNT++))
fi

# 2.2 Verify Ingress Rules Configurations
check_k8s_resource ingress "$INGRESS_NAME" "$NAMESPACE" "" "{.spec.rules[0].host}" "$EXPECTED_HOST"
check_k8s_resource ingress "$INGRESS_NAME" "$NAMESPACE" "" "{.spec.rules[0].http.paths[0].path}" "$EXPECTED_PATH"
check_k8s_resource ingress "$INGRESS_NAME" "$NAMESPACE" "" "{.spec.rules[0].http.paths[0].pathType}" "$EXPECTED_PATHTYPE"
check_k8s_resource ingress "$INGRESS_NAME" "$NAMESPACE" "" "{.spec.rules[0].http.paths[0].backend.service.name}" "$SVC_NAME"

# 2.3 Verify Service Port Mapping in Ingress
ING_PORT=$(kubectl get ingress "$INGRESS_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
ING_PORT_NAME=$(kubectl get ingress "$INGRESS_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.name}' 2>/dev/null)

SVC_PORTS=$(kubectl get svc "$SVC_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.ports[*].port}' 2>/dev/null)
SVC_PORT_NAMES=$(kubectl get svc "$SVC_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.ports[*].name}' 2>/dev/null)

if [ -n "$ING_PORT" ]; then
    # Checking if the requested port number exists in the service
    if [[ " $SVC_PORTS " == *" $ING_PORT "* ]]; then
        log "PASS" "Ingress correctly maps to backend port $ING_PORT, which is exposed by Service '$SVC_NAME'."
        ((PASS_COUNT++))
    else
        log "FAIL" "Ingress maps to backend port $ING_PORT, but Service '$SVC_NAME' only exposes ports: [$SVC_PORTS]."
        ((FAIL_COUNT++))
    fi
elif [ -n "$ING_PORT_NAME" ]; then
    # Checking if the requested port name exists in the service
    if [[ " $SVC_PORT_NAMES " == *" $ING_PORT_NAME "* ]]; then
        log "PASS" "Ingress correctly maps to backend port name '$ING_PORT_NAME', which is exposed by Service '$SVC_NAME'."
        ((PASS_COUNT++))
    else
        log "FAIL" "Ingress maps to backend port name '$ING_PORT_NAME', but Service '$SVC_NAME' only exposes port names: [$SVC_PORT_NAMES]."
        ((FAIL_COUNT++))
    fi
else
    log "FAIL" "Could not determine a backend service port number or name in Ingress '$INGRESS_NAME'."
    ((FAIL_COUNT++))
fi

# --- Task 3: Test Reachability ---
log "INFO" "Testing accessibility of $URL (Checking for HTTP 200)..."

HTTP_CODE="000"
# Loop to wait for Ingress Controller to process the rule and be ready
for i in {1..6}; do
    # Suppress output, follow redirects, timeout of 3s, and just capture HTTP code
    HTTP_CODE=$(curl -s -L -o /dev/null -w "%{http_code}" --max-time 3 "$URL" || echo "000")
    if [ "$HTTP_CODE" == "200" ]; then
        break
    fi
    sleep 3
done

if [ "$HTTP_CODE" == "200" ]; then
    log "PASS" "Service is reachable! Successfully received HTTP 200 from $URL."
    ((PASS_COUNT++))
elif [ "$HTTP_CODE" == "000" ]; then
    log "FAIL" "Failed to reach $URL. (Host not resolved / Connection Refused). Is your local /etc/hosts set correctly to the Ingress NodeIP?"
    ((FAIL_COUNT++))
else
    log "FAIL" "Reached $URL, but received unexpected HTTP status: $HTTP_CODE (Expected 200)."
    ((FAIL_COUNT++))
fi

# ==========================================
# RESULTS SUMMARY
# ==========================================

print_summary_and_exit