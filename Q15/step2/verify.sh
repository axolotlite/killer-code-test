#!/bin/bash
# verify-pods.sh - Control Plane Pod Validation

# 1. Source the utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/utility.sh" ]; then
  source "$SCRIPT_DIR/utility.sh"
else
  echo "[FATAL] utility.sh not found in $SCRIPT_DIR"
  exit 1
fi

# 2. Define target variables
NS="kube-system"
PODS=("kube-controller-manager" "kube-scheduler")
RANGE="100:200"

# ==========================================
# EXECUTION BLOCK
# ==========================================

log "INFO" "Running Control Plane Pod Validations..."
echo "" | tee -a "$OUTPUT_FILE"

for BASE_POD in "${PODS[@]}"; do
    POD="$BASE_POD-$(hostname)"
    
    # 1. Check if Pod exists and is Running
    check_k8s_resource "pod" "$POD" "$NS" "" "{.status.phase}" "Running"
    
    # 2. Check CPU threshold is between 100m and 200m
    # Format: check_k8s_resource <kind> <name> <ns> <sel> <jsonpath> <expected_val> <operator>
    check_k8s_resource "pod" "$POD" "$NS" "" "{.spec.containers[0].resources.requests.cpu}" "$RANGE" "range"

done

# ==========================================
# RESULTS SUMMARY
# ==========================================
print_summary_and_exit