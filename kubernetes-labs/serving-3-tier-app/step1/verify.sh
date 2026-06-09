#!/bin/bash
# verify.sh - Step 1: Backend Service Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../assets/utility.sh"

NS="default"

log "INFO" "Validating Step 1: Backend Service..."
echo "" | tee -a "$OUTPUT_FILE"

# Check containerPort is set on the backend deployment
check_k8s_resource deployment "store-backend" "$NS" "" '{.spec.template.spec.containers[0].ports[0].containerPort}' "5000"

# Check service exists with correct config
check_k8s_resource service "backend-svc" "$NS"
check_k8s_resource service "backend-svc" "$NS" "" '{.spec.type}' "ClusterIP"
check_k8s_resource service "backend-svc" "$NS" "" '{.spec.ports[0].port}' "5000"
check_k8s_resource service "backend-svc" "$NS" "" '{.spec.ports[0].targetPort}' "5000"

print_summary_and_exit
