#!/bin/bash
# verify.sh - CNI Installation Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

log "INFO" "Running CNI Validations..."
echo "" | tee -a "$OUTPUT_FILE"

NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
check_k8s_resource node "$NODE_NAME" "" "" '{.status.conditions[?(@.type=="Ready")].status}' "True"
check_k8s_resource pod "" "kube-system" "k8s-app=kube-dns" '{.items[0].status.phase}' "Running"

HAS_CALICO=$(kubectl get ds -n calico-system calico-node --ignore-not-found -o name)
HAS_FLANNEL=$(kubectl get ds -n kube-flannel kube-flannel-ds --ignore-not-found -o name)

if [ -n "$HAS_CALICO" ] || [ -n "$HAS_FLANNEL" ]; then
  log "PASS" "Detected CNI installation."
  ((PASS_COUNT++))
else
  log "FAIL" "No supported CNI components found."
  ((FAIL_COUNT++))
fi

kubectl run cni-test-1 --image=busybox --restart=Never -- sleep 3600 >/dev/null 2>&1
kubectl run cni-test-2 --image=busybox --restart=Never -- sleep 3600 >/dev/null 2>&1
kubectl wait --for=condition=Ready pod/cni-test-1 pod/cni-test-2 --timeout=20s >/dev/null 2>&1

POD2_IP=$(kubectl get pod cni-test-2 -o jsonpath='{.status.podIP}' 2>/dev/null)
if [ -n "$POD2_IP" ] && kubectl exec cni-test-1 -- ping -c 1 -W 2 "$POD2_IP" >/dev/null 2>&1; then
  log "PASS" "Pod-to-Pod communication ping test was successful."
  ((PASS_COUNT++))
else
  log "FAIL" "Pod-to-Pod communication failed."
  ((FAIL_COUNT++))
fi

kubectl delete pod cni-test-1 cni-test-2 --force --grace-period=0 >/dev/null 2>&1
print_summary_and_exit