#!/bin/bash
# verify.sh - CKA Lab 10: Taints and Tolerations
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

log "INFO" "Running Taints and Tolerations Validations..."
echo "" | tee -a "$OUTPUT_FILE"

check_k8s_resource node "node01" "" "" "{.spec.taints[?(@.key==\"PERMISSION\")].value}" "granted"
check_k8s_resource pod "nginx" "default" "" "{.spec.containers[0].image}" "nginx:stable"
check_k8s_resource pod "nginx" "default" "" "{.spec.nodeName}" "node01"
check_k8s_resource pod "nginx" "default" "" "{.status.phase}" "Running"

print_summary_and_exit