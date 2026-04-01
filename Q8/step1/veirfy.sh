#!/bin/bash
# verify.sh - CNI Installation Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

# 1. Source the utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/utility.sh" ]; then
  source "$SCRIPT_DIR/utility.sh"
else
  echo "[FATAL] utility.sh not found in $SCRIPT_DIR" | tee -a "$OUTPUT_FILE"
  pwd | tee -a "$OUTPUT_FILE"
  ls | tee -a "$OUTPUT_FILE"
  exit 1
fi

# ==========================================
# EXECUTION BLOCK
# ==========================================

log "INFO" "Running CNI Installation Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# 1. Check if the Node is Ready (requires a working CNI)
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
check_k8s_resource node "$NODE_NAME" "" "" '{.status.conditions[?(@.type=="Ready")].status}' "True"

# 2. Check if CoreDNS pods are Running (they will be stuck in Pending/ContainerCreating without a CNI)
check_k8s_resource pod "" "kube-system" "k8s-app=kube-dns" '{.items[0].status.phase}' "Running"

# 3. Check for specific CNI installation components
log "INFO" "Checking if a valid CNI manifest was applied..."
HAS_CALICO_OP=$(kubectl get deploy -n tigera-operator tigera-operator --ignore-not-found -o name)
HAS_CALICO_SYS=$(kubectl get ds -n calico-system calico-node --ignore-not-found -o name)
HAS_FLANNEL=$(kubectl get ds -n kube-flannel kube-flannel-ds --ignore-not-found -o name)

if [ -n "$HAS_CALICO_OP" ] || [ -n "$HAS_CALICO_SYS" ] || [ -n "$HAS_FLANNEL" ]; then
  log "PASS" "Detected CNI installation (Calico or Flannel)."
  ((PASS_COUNT++))
else
  log "FAIL" "No supported CNI components (Calico or Flannel) found."
  ((FAIL_COUNT++))
fi

# 4. Check NetworkPolicy support based on installed CNI
if [ -n "$HAS_FLANNEL" ]; then
  log "WARN" "Flannel is installed. Note that Flannel does NOT natively support NetworkPolicies."
  ((WARN_COUNT++))
elif [ -n "$HAS_CALICO_OP" ] || [ -n "$HAS_CALICO_SYS" ]; then
  log "PASS" "Calico is installed. NetworkPolicies are supported."
  ((PASS_COUNT++))
fi

# 5. Pod-to-Pod Communication Test
log "INFO" "Testing live Pod-to-Pod communication..."
kubectl run cni-test-1 --image=busybox --restart=Never -- sleep 3600 >/dev/null 2>&1
kubectl run cni-test-2 --image=busybox --restart=Never -- sleep 3600 >/dev/null 2>&1

# Wait for pods to run (up to 45 seconds to account for image pulls/CNI setup)
kubectl wait --for=condition=Ready pod/cni-test-1 pod/cni-test-2 --timeout=45s >/dev/null 2>&1

POD2_IP=$(kubectl get pod cni-test-2 -o jsonpath='{.status.podIP}' 2>/dev/null)

if [ -n "$POD2_IP" ] && kubectl exec cni-test-1 -- ping -c 1 -W 2 "$POD2_IP" >/dev/null 2>&1; then
  log "PASS" "Pod-to-Pod communication ping test was successful."
  ((PASS_COUNT++))
else
  log "FAIL" "Pod-to-Pod communication failed or test pods did not become ready."
  ((FAIL_COUNT++))
fi

# Clean up test pods silently
kubectl delete pod cni-test-1 cni-test-2 --force --grace-period=0 >/dev/null 2>&1

# ==========================================
# RESULTS SUMMARY
# ==========================================

print_summary_and_exit