#!/bin/bash
# verify.sh - Step 2: Backend Environment Variables
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

NS="default"

log "INFO" "Validating Step 2: Backend Environment Variables..."
echo "" | tee -a "$OUTPUT_FILE"

# Direct values
check_k8s_resource deployment "store-backend" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="DB_HOST")].value}' "database-svc"
check_k8s_resource deployment "store-backend" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="DB_PORT")].value}' "5432"

# Secret references
check_k8s_resource deployment "store-backend" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="DB_NAME")].valueFrom.secretKeyRef.name}' "db-credentials"
check_k8s_resource deployment "store-backend" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="DB_NAME")].valueFrom.secretKeyRef.key}' "POSTGRES_DB"
check_k8s_resource deployment "store-backend" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="DB_USER")].valueFrom.secretKeyRef.name}' "db-credentials"
check_k8s_resource deployment "store-backend" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="DB_USER")].valueFrom.secretKeyRef.key}' "POSTGRES_USER"
check_k8s_resource deployment "store-backend" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="DB_PASSWORD")].valueFrom.secretKeyRef.name}' "db-credentials"
check_k8s_resource deployment "store-backend" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="DB_PASSWORD")].valueFrom.secretKeyRef.key}' "POSTGRES_PASSWORD"

print_summary_and_exit
