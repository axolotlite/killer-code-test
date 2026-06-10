#!/bin/bash
# verify.sh - Step 1: Database Secret & Environment Variables
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

NS="default"

log "INFO" "Validating Step 1: Database Secret & Environment Variables..."
echo "" | tee -a "$OUTPUT_FILE"

# Verify secret exists with correct data
check_k8s_resource secret "db-credentials" "$NS"

# Verify StatefulSet references the secret
check_k8s_resource statefulset "store-db" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="POSTGRES_DB")].valueFrom.secretKeyRef.name}' "db-credentials"
check_k8s_resource statefulset "store-db" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="POSTGRES_DB")].valueFrom.secretKeyRef.key}' "POSTGRES_DB"
check_k8s_resource statefulset "store-db" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="POSTGRES_USER")].valueFrom.secretKeyRef.name}' "db-credentials"
check_k8s_resource statefulset "store-db" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="POSTGRES_USER")].valueFrom.secretKeyRef.key}' "POSTGRES_USER"
check_k8s_resource statefulset "store-db" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="POSTGRES_PASSWORD")].valueFrom.secretKeyRef.name}' "db-credentials"
check_k8s_resource statefulset "store-db" "$NS" "" '{.spec.template.spec.containers[0].env[?(@.name=="POSTGRES_PASSWORD")].valueFrom.secretKeyRef.key}' "POSTGRES_PASSWORD"

print_summary_and_exit
