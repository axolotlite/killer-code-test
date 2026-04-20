#!/bin/bash
# verify.sh - CKA Lab 12: Ingress Configuration
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

NAMESPACE="echo-app"
SVC_NAME="echo-service"
INGRESS_NAME="echo"
EXPECTED_HOST="echo-service.org"
EXPECTED_PATH="/echo"

log "INFO" "Running Ingress Configuration Validations..."
echo "" | tee -a "$OUTPUT_FILE"

check_k8s_resource svc "$SVC_NAME" "$NAMESPACE" "" "{.spec.type}" "NodePort"

check_k8s_resource ingress "$INGRESS_NAME" "$NAMESPACE" "" "{.spec.rules[0].host}" "$EXPECTED_HOST"
check_k8s_resource ingress "$INGRESS_NAME" "$NAMESPACE" "" "{.spec.rules[0].http.paths[0].path}" "$EXPECTED_PATH"
check_k8s_resource ingress "$INGRESS_NAME" "$NAMESPACE" "" "{.spec.rules[0].http.paths[0].backend.service.name}" "$SVC_NAME"

check_http_status "http://${EXPECTED_HOST}${EXPECTED_PATH}" "200" 6 3

print_summary_and_exit