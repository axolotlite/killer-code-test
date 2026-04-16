#!/bin/bash
# verify.sh - Controlplane Troubleshooting Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation-1.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

log "INFO" "Running Controlplane Troubleshooting Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# Standard kubeadm path for the kube-apiserver static pod manifest
MANIFEST_FILE="/etc/kubernetes/manifests/kube-apiserver.yaml"

# 1. Check if the kube-apiserver manifest was fixed
# Note: We omit the leading dashes in the regex (etcd-servers) to prevent 'grep' from parsing it as an invalid command-line flag inside 'check_local_file'.
check_local_file "$MANIFEST_FILE" "etcd-servers=https://127\.0\.0\.1:2379"

# 2. Check if the Kubernetes API has recovered and is reachable
log "INFO" "Testing Kubernetes API reachability..."
if kubectl get --raw='/readyz' >/dev/null 2>&1 || kubectl get nodes >/dev/null 2>&1; then
  log "PASS" "Kubernetes API is reachable and responding successfully."
  ((PASS_COUNT++))
else
  log "FAIL" "Kubernetes API is NOT reachable. The apiserver might still be crashing."
  ((FAIL_COUNT++))
fi

print_summary_and_exit