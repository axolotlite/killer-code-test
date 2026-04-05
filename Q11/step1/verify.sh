#!/bin/bash
# verify.sh - Gateway API Migration Validation
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
NAMESPACE="web-app"

GATEWAY_NAME="web-gateway"
ROUTE_NAME="web-route"
EXPECTED_HOSTNAME="gateway.web.k8s.local"
EXPECTED_GW_CLASS="cluster-gateway"
EXPECTED_SECRET="web-tls"
EXPECTED_PROTOCOL="HTTPS"
EXPECTED_PORT="443"

EXPECTED_SERVICE="web-service"
EXPECTED_SVC_PORT="80"
EXPECTED_PATH="/"
EXPECTED_PATH_TYPE="PathPrefix"

# ==========================================
# EXECUTION BLOCK
# ==========================================

log "INFO" "Running Gateway API Migration Validations in namespace: $NAMESPACE..."
echo "" | tee -a "$OUTPUT_FILE"

# --- GATEWAY CHECKS ---
log "INFO" "Checking Gateway Configuration..."

# 1. Gateway Existence
check_k8s_resource gateway "$GATEWAY_NAME" "$NAMESPACE" "" "" ""

# 2. GatewayClass
check_k8s_resource gateway "$GATEWAY_NAME" "$NAMESPACE" "" '{.spec.gatewayClassName}' "$EXPECTED_GW_CLASS"

# 3. Listener Hostname
check_k8s_resource gateway "$GATEWAY_NAME" "$NAMESPACE" "" '{.spec.listeners[0].hostname}' "$EXPECTED_HOSTNAME"

# 4. Listener Protocol
check_k8s_resource gateway "$GATEWAY_NAME" "$NAMESPACE" "" '{.spec.listeners[0].protocol}' "$EXPECTED_PROTOCOL"

# 5. Listener Port
check_k8s_resource gateway "$GATEWAY_NAME" "$NAMESPACE" "" '{.spec.listeners[0].port}' "$EXPECTED_PORT"

# 6. TLS Secret Reference
check_k8s_resource gateway "$GATEWAY_NAME" "$NAMESPACE" "" '{.spec.listeners[0].tls.certificateRefs[0].name}' "$EXPECTED_SECRET"


echo "" | tee -a "$OUTPUT_FILE"
# --- HTTPROUTE CHECKS ---
log "INFO" "Checking HTTPRoute Configuration..."

# 7. HTTPRoute Existence
check_k8s_resource httproute "$ROUTE_NAME" "$NAMESPACE" "" "" ""

# 8. Parent Gateway Reference
check_k8s_resource httproute "$ROUTE_NAME" "$NAMESPACE" "" '{.spec.parentRefs[0].name}' "$GATEWAY_NAME"

# 9. Route Hostname
check_k8s_resource httproute "$ROUTE_NAME" "$NAMESPACE" "" '{.spec.hostnames[0]}' "$EXPECTED_HOSTNAME"

# 10. Path Match Value
check_k8s_resource httproute "$ROUTE_NAME" "$NAMESPACE" "" '{.spec.rules[0].matches[0].path.value}' "$EXPECTED_PATH"

# 11. Path Match Type
check_k8s_resource httproute "$ROUTE_NAME" "$NAMESPACE" "" '{.spec.rules[0].matches[0].path.type}' "$EXPECTED_PATH_TYPE"

# 12. Backend Service Reference
check_k8s_resource httproute "$ROUTE_NAME" "$NAMESPACE" "" '{.spec.rules[0].backendRefs[0].name}' "$EXPECTED_SERVICE"

# 13. Backend Service Port
check_k8s_resource httproute "$ROUTE_NAME" "$NAMESPACE" "" '{.spec.rules[0].backendRefs[0].port}' "$EXPECTED_SVC_PORT"

# ==========================================
# RESULTS SUMMARY
# ==========================================

# Print kube-bench style matrix and exit 0 or 1
print_summary_and_exit