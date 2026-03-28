#!/bin/bash
# verify.sh - StorageClass Validation

# 1. Source the utility library
SCRIPT_DIR=""$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)""
if [ -f "$SCRIPT_DIR/utility.sh" ]; then
  source "$SCRIPT_DIR/utility.sh"
else
  echo "[FATAL] utility.sh not found in $SCRIPT_DIR"
  exit 1
fi

# 2. Define expected state
SC_NAME="local-storage"
EXPECTED_PROVISIONER="rancher.io/local-path"
EXPECTED_MODE="WaitForFirstConsumer"
EXPECTED_DEFAULT="true"

# ==========================================
# EXECUTION BLOCK
# ==========================================

log "INFO" "Running StorageClass Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# 1. Existence
check_k8s_resource sc "$SC_NAME" "" "" "" ""

# 2. Provisioner
check_k8s_resource sc "$SC_NAME" "" "" '{.provisioner}' "$EXPECTED_PROVISIONER"

# 3. VolumeBindingMode
check_k8s_resource sc "$SC_NAME" "" "" '{.volumeBindingMode}' "$EXPECTED_MODE"

# 4. Default annotation
check_k8s_resource sc "$SC_NAME" "" "" '{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}' "$EXPECTED_DEFAULT"

# 5. Check for other defaults (Custom scripted check utilizing global counters)
other_defaults=$(kubectl get sc -o jsonpath='{range .items[*]}{.metadata.name}{"="}{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}' | grep "=true" | grep -v "^$SC_NAME=" || true)

if [ -n "$other_defaults" ]; then
  log "FAIL" "Multiple default StorageClasses detected"
  echo "$other_defaults" | tee -a "$OUTPUT_FILE"
  ((FAIL_COUNT++))
else
  log "PASS" "No other default StorageClasses found"
  ((PASS_COUNT++))
fi

# ==========================================
# RESULTS SUMMARY
# ==========================================

# Print kube-bench style matrix and exit 0 or 1
print_summary_and_exit