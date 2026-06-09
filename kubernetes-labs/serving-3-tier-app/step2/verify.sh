#!/bin/bash
# verify.sh - Step 2: Database Service Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

NS="default"

log "INFO" "Validating Step 2: Database Service..."
echo "" | tee -a "$OUTPUT_FILE"

# Check containerPort is set on the database statefulset
check_k8s_resource statefulset "store-db" "$NS" "" '{.spec.template.spec.containers[0].ports[0].containerPort}' "5432"

# Check service exists with correct config
check_k8s_resource service "database-svc" "$NS"
check_k8s_resource service "database-svc" "$NS" "" '{.spec.type}' "ClusterIP"
check_k8s_resource service "database-svc" "$NS" "" '{.spec.ports[0].port}' "5432"
check_k8s_resource service "database-svc" "$NS" "" '{.spec.ports[0].targetPort}' "5432"

print_summary_and_exit
