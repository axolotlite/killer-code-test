#!/bin/bash
# verify.sh - Step 1: Database Environment Variables
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../assets/utility.sh"

NS="default"

log "INFO" "Validating Step 1: Database Environment Variables..."
echo "" | tee -a "$OUTPUT_FILE"

check_k8s_resource statefulset "store-db" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="POSTGRES_DB")].value}' "appdb"
check_k8s_resource statefulset "store-db" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="POSTGRES_USER")].value}' "appuser"
check_k8s_resource statefulset "store-db" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="POSTGRES_PASSWORD")].value}' "apppassword"

print_summary_and_exit
