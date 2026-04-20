#!/bin/bash
# verify.sh - StorageClass Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

SC_NAME="custom-storage"

log "INFO" "Running StorageClass Validations..."
echo "" | tee -a "$OUTPUT_FILE"

check_k8s_resource sc "$SC_NAME" "" "" '{.provisioner}' "rancher.io/local-path"
check_k8s_resource sc "$SC_NAME" "" "" '{.volumeBindingMode}' "WaitForFirstConsumer"
check_k8s_resource sc "$SC_NAME" "" "" '{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}' "true"

other_defaults=$(kubectl get sc -o jsonpath='{range .items[*]}{.metadata.name}{"="}{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}' | grep "=true" | grep -v "^$SC_NAME=" || true)
if [ -n "$other_defaults" ]; then
  log "FAIL" "Multiple default StorageClasses detected."
  ((FAIL_COUNT++))
else
  log "PASS" "Only one default StorageClass exists."
  ((PASS_COUNT++))
fi

print_summary_and_exit