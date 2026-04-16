#!/bin/bash
# verify-pods.sh - Control Plane Pod Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation-2.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

NS="kube-system"
PODS=("kube-controller-manager" "kube-scheduler")
RANGE="100:200"

log "INFO" "Running Control Plane Pod Validations..."
echo "" | tee -a "$OUTPUT_FILE"

for BASE_POD in "${PODS[@]}"; do
    POD="$BASE_POD-$(hostname)"
    
    # 1. Check if Pod exists and is Running
    check_k8s_resource "pod" "$POD" "$NS" "" "{.status.phase}" "Running"
    
    # 2. Check CPU and Memory thresholds fall within the 100 to 200 range
    check_k8s_resource "pod" "$POD" "$NS" "" "{.spec.containers[0].resources.limits.cpu}" "$RANGE" "range"
    check_k8s_resource "pod" "$POD" "$NS" "" "{.spec.containers[0].resources.limits.memory}" "$RANGE" "range"
    
    check_k8s_resource "pod" "$POD" "$NS" "" "{.spec.containers[0].resources.requests.cpu}" "$RANGE" "range"
    check_k8s_resource "pod" "$POD" "$NS" "" "{.spec.containers[0].resources.requests.memory}" "$RANGE" "range"
done

print_summary_and_exit