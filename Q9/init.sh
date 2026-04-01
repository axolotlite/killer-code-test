#!/bin/bash
# init.sh - Prepares the Killercoda environment for the cri-dockerd SWITCH lab

echo "Starting environment setup for cri-dockerd lab..."

# 1. Download the required .deb package for the user
CRI_DOCKERD_VERSION="0.3.14"
CRI_DOCKERD_URL="https://github.com/Mirantis/cri-dockerd/releases/download/v${CRI_DOCKERD_VERSION}/cri-dockerd_${CRI_DOCKERD_VERSION}.3-0.ubuntu-jammy_amd64.deb"
DEB_PACKAGE_NAME="cri-dockerd.deb"

echo "Downloading $DEB_PACKAGE_NAME..."
wget -q -O "/root/$DEB_PACKAGE_NAME" "$CRI_DOCKERD_URL"
if [ $? -ne 0 ]; then
    echo "FATAL: Failed to download cri-dockerd.deb."
    exit 1
fi
echo "Package is available at /root/$DEB_PACKAGE_NAME"

# 2. Ensure cri-dockerd is not installed or running
echo "Ensuring cri-dockerd service is stopped and uninstalled..."
systemctl stop cri-dockerd.service >/dev/null 2>&1
systemctl disable cri-dockerd.service >/dev/null 2>&1
apt-get remove -y --purge cri-dockerd >/dev/null 2>&1

# 3. CRITICAL: Ensure Kubelet is configured to use containerd
# Killercoda uses a systemd drop-in file for kubelet args. We will ensure it points to containerd.
KUBELET_DROPIN_DIR="/etc/systemd/system/kubelet.service.d"
KUBELET_CONF_FILE="$KUBELET_DROPIN_DIR/10-kubeadm.conf"
CONTAINERD_SOCK="unix:///run/containerd/containerd.sock"

echo "Ensuring kubelet is configured for containerd..."
if [ -f "$KUBELET_CONF_FILE" ]; then
    # Use sed to find the line with --container-runtime-endpoint and replace it
    sed -i "s|--container-runtime-endpoint=.*\"|--container-runtime-endpoint=${CONTAINERD_SOCK}\"|g" "$KUBELET_CONF_FILE"
else
    echo "FATAL: Kubelet configuration file not found at $KUBELET_CONF_FILE"
    exit 1
fi

# 4. Reset sysctl parameters and remove any persistent config
echo "Resetting kernel parameters and cleaning persistent config..."
sysctl -w net.bridge.bridge-nf-call-iptables=0
sysctl -w net.ipv6.conf.all.forwarding=0
sysctl -w net.ipv4.ip_forward=0
rm -f /etc/sysctl.d/99-kubernetes-cri.conf

# 5. Reload and restart kubelet to apply the containerd config
echo "Applying clean configuration..."
systemctl daemon-reload
systemctl restart kubelet

echo "Initialization complete. The node is running with containerd."