#!/bin/bash
# verify.sh - Step 3: Frontend Environment Variables
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

NS="default"

log "INFO" "Validating Step 3: Frontend Environment Variables..."
echo "" | tee -a "$OUTPUT_FILE"

check_k8s_resource deployment "store-frontend" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="BACKEND_HOST")].value}' "backend-svc"
check_k8s_resource deployment "store-frontend" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="BACKEND_PORT")].value}' "5000"

print_summary_and_exit
