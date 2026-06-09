#!/bin/bash
# verify.sh - Step 3: Frontend Service Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../assets/utility.sh"

NS="default"

log "INFO" "Validating Step 3: Frontend Service..."
echo "" | tee -a "$OUTPUT_FILE"

# Check containerPort is set on the frontend deployment
check_k8s_resource deployment "store-frontend" "$NS" "" '{.spec.template.spec.containers[0].ports[0].containerPort}' "8080"

# Check service exists with correct config
check_k8s_resource service "frontend-svc" "$NS"
check_k8s_resource service "frontend-svc" "$NS" "" '{.spec.type}' "NodePort"
check_k8s_resource service "frontend-svc" "$NS" "" '{.spec.ports[0].port}' "8080"
check_k8s_resource service "frontend-svc" "$NS" "" '{.spec.ports[0].nodePort}' "38080"

print_summary_and_exit
