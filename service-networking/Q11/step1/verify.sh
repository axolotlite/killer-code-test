#!/bin/bash
# verify.sh - Gateway API Migration Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

NAMESPACE="web-app"
GATEWAY_NAME="web-gateway"
ROUTE_NAME="web-route"

log "INFO" "Running Gateway API Migration Validations..."
echo "" | tee -a "$OUTPUT_FILE"

check_k8s_resource gateway "$GATEWAY_NAME" "$NAMESPACE" "" '{.spec.gatewayClassName}' "cluster-gateway"
check_k8s_resource gateway "$GATEWAY_NAME" "$NAMESPACE" "" '{.spec.listeners[0].hostname}' "gateway.web.k8s.local"
check_k8s_resource gateway "$GATEWAY_NAME" "$NAMESPACE" "" '{.spec.listeners[0].tls.certificateRefs[0].name}' "web-tls"

check_k8s_resource httproute "$ROUTE_NAME" "$NAMESPACE" "" '{.spec.parentRefs[0].name}' "$GATEWAY_NAME"
check_k8s_resource httproute "$ROUTE_NAME" "$NAMESPACE" "" '{.spec.hostnames[0]}' "gateway.web.k8s.local"
check_k8s_resource httproute "$ROUTE_NAME" "$NAMESPACE" "" '{.spec.rules[0].matches[0].path.value}' "/"
check_k8s_resource httproute "$ROUTE_NAME" "$NAMESPACE" "" '{.spec.rules[0].backendRefs[0].name}' "web-service"
check_k8s_resource httproute "$ROUTE_NAME" "$NAMESPACE" "" '{.spec.rules[0].backendRefs[0].port}' "80"

print_summary_and_exit