#!/bin/bash
# verify.sh - CKA Lab 07: PriorityClass
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

log "INFO" "Running PriorityClass Validations..."
echo "" | tee -a "$OUTPUT_FILE"

base_value=$(kubectl get priorityclass "user-critical" -o jsonpath='{.value}' 2>/dev/null || echo "0")
expected_value=$((base_value - 1))

check_k8s_resource priorityclass "high-priority" "" "" "{.value}" "$expected_value"
check_k8s_resource deploy "busybox-logger" "priority" "" "{.spec.template.spec.priorityClassName}" "high-priority"

print_summary_and_exit