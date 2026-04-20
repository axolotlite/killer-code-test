#!/bin/bash
# init.sh - Prepares a MULTI-NODE Killercoda environment by removing the default Cilium CNI

echo "Starting CNI cleanup across all nodes..."

# 1. Perform cluster-wide resource deletion from the control plane first.
# This only needs to be run once.
echo "Deleting cluster-wide CNI resources (Deployments, DaemonSets, Helm releases, CRDs)..."
helm uninstall cilium -n kube-system >/dev/null 2>&1
kubectl delete ds cilium -n kube-system --ignore-not-found
kubectl delete deploy cilium-operator -n kube-system --ignore-not-found
# Also remove Cilium CRDs for a full cleanup
kubectl delete crd ciliumidentities.cilium.io ciliumnodes.cilium.io ciliumendpoints.cilium.io ciliumnetworkpolicies.cilium.io ciliumclusterwidenetworkpolicies.cilium.io --ignore-not-found >/dev/null 2>&1

# 2. Define the set of commands to run on EACH node.
# Using a heredoc makes it clean and easy to read/modify.
# The 'EOF' is quoted to prevent local variable expansion inside the block.
read -r -d '' NODE_CLEANUP_CMDS <<'EOF'
echo "  - Removing CNI config files from /etc/cni/net.d/..."
rm -f /etc/cni/net.d/*cilium*.conflist

echo "  - Removing Cilium runtime directories..."
rm -rf /var/run/cilium

echo "  - Removing Cilium network interfaces..."
ip link delete cilium_host >/dev/null 2>&1
ip link delete cilium_net >/dev/null 2>&1

echo "  - Restarting container runtime and kubelet..."
systemctl restart containerd
systemctl restart kubelet
echo "  - Done."
EOF

# 3. Get all node hostnames and iterate through them.
# This makes the script work for 1, 2, or N nodes dynamically.
ALL_NODES=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}')

for node in $ALL_NODES; do
    echo "----------------------------------------"
    echo "Executing cleanup on node: $node"
    # Use SSH to run the block of commands on each node.
    # The -q (quiet) and StrictHostKeyChecking=no are best practices for automation.
    ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$node" "$NODE_CLEANUP_CMDS"
done

echo "----------------------------------------"
echo "All nodes have been cleaned. Waiting for cluster to settle..."
sleep 10
echo "Initialization complete. All nodes should now be in a 'NotReady' state, awaiting a new CNI."