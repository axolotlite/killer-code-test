#!/bin/bash
# verify.sh - Step 2: Backend Environment Variables
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../assets/utility.sh"

NS="default"

log "INFO" "Validating Step 2: Backend Environment Variables..."
echo "" | tee -a "$OUTPUT_FILE"

check_k8s_resource deployment "store-backend" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="DB_HOST")].value}' "database-svc"
check_k8s_resource deployment "store-backend" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="DB_PORT")].value}' "5432"
check_k8s_resource deployment "store-backend" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="DB_NAME")].value}' "appdb"
check_k8s_resource deployment "store-backend" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="DB_USER")].value}' "appuser"
check_k8s_resource deployment "store-backend" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="DB_PASSWORD")].value}' "apppassword"

print_summary_and_exit
