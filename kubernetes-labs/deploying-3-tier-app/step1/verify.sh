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

# --- Backend Deployment ---
check_k8s_resource deployment "$BACKEND" "$NS"
check_k8s_resource deployment "$BACKEND" "$NS" "" '{.spec.template.spec.containers[0].image}' "ghcr.io/axolotlite/killer-code-test/managed-app/dummy-store-backend"
check_k8s_resource deployment "$BACKEND" "$NS" "" '{.spec.template.spec.containers[0].resources.requests.cpu}' "100m"
check_k8s_resource deployment "$BACKEND" "$NS" "" '{.spec.template.spec.containers[0].resources.requests.memory}' "100M"
check_k8s_resource deployment "$BACKEND" "$NS" "" '{.spec.template.spec.containers[0].resources.limits.cpu}' "400m"
check_k8s_resource deployment "$BACKEND" "$NS" "" '{.spec.template.spec.containers[0].resources.limits.memory}' "500M"

# --- Frontend Deployment ---
check_k8s_resource deployment "$FRONTEND" "$NS"
check_k8s_resource deployment "$FRONTEND" "$NS" "" '{.spec.template.spec.containers[0].image}' "ghcr.io/axolotlite/killer-code-test/managed-app/dummy-store-frontend"
check_k8s_resource deployment "$FRONTEND" "$NS" "" '{.spec.template.spec.containers[0].resources.requests.cpu}' "10m"
check_k8s_resource deployment "$FRONTEND" "$NS" "" '{.spec.template.spec.containers[0].resources.requests.memory}' "50M"
check_k8s_resource deployment "$FRONTEND" "$NS" "" '{.spec.template.spec.containers[0].resources.limits.cpu}' "400m"
check_k8s_resource deployment "$FRONTEND" "$NS" "" '{.spec.template.spec.containers[0].resources.limits.memory}' "500M"

# --- Database StatefulSet ---
check_k8s_resource statefulset "$DATABASE" "$NS"
check_k8s_resource statefulset "$DATABASE" "$NS" "" '{.spec.template.spec.containers[0].image}' "postgres:14.23-alpine3.23"
check_k8s_resource statefulset "$DATABASE" "$NS" "" '{.spec.template.spec.containers[0].resources.requests.cpu}' "100m"
check_k8s_resource statefulset "$DATABASE" "$NS" "" '{.spec.template.spec.containers[0].resources.requests.memory}' "200M"
check_k8s_resource statefulset "$DATABASE" "$NS" "" '{.spec.template.spec.containers[0].resources.limits.cpu}' "600m"
check_k8s_resource statefulset "$DATABASE" "$NS" "" '{.spec.template.spec.containers[0].resources.limits.memory}' "1000M"

print_summary_and_exit
