#!/bin/bash
# verify.sh - Step 1: Resource Requests and Limits Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

NS="default"
BACKEND="store-backend"
FRONTEND="store-frontend"
DATABASE="store-db"

log "INFO" "Validating Step 1: Resource Requests and Limits..."
echo "" | tee -a "$OUTPUT_FILE"

# --- Database StatefulSet ---
check_k8s_resource statefulset "$DATABASE" "$NS"
check_k8s_resource statefulset "$DATABASE" "$NS" "" '{.spec.template.spec.containers[0].image}' "postgres:14.23-alpine3.23"
check_k8s_resource statefulset "$DATABASE" "$NS" "" '{.spec.template.spec.containers[0].resources.requests.cpu}' "10m"
check_k8s_resource statefulset "$DATABASE" "$NS" "" '{.spec.template.spec.containers[0].resources.requests.memory}' "200Mi"
check_k8s_resource statefulset "$DATABASE" "$NS" "" '{.spec.template.spec.containers[0].resources.limits.cpu}' "60m"
check_k8s_resource statefulset "$DATABASE" "$NS" "" '{.spec.template.spec.containers[0].resources.limits.memory}' "1000Mi"

print_summary_and_exit
