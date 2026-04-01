#!/bin/bash
# init.sh - Prepares Killercoda environment for CKA Lab 09

# 1. Download the cri-dockerd package
CRI_DOCKERD_VERSION="0.3.15"
UBUNTU_CODENAME=$(lsb_release -cs)

if [[ "$UBUNTU_CODENAME" != "jammy" && "$UBUNTU_CODENAME" != "focal" ]]; then
  UBUNTU_CODENAME="focal"
fi

wget -qO /root/cri-dockerd.deb "https://github.com/Mirantis/cri-dockerd/releases/download/v${CRI_DOCKERD_VERSION}/cri-dockerd_${CRI_DOCKERD_VERSION}.3-0.ubuntu-${UBUNTU_CODENAME}_amd64.deb"

# 2. Ensure service is stopped/removed just in case
systemctl stop cri-docker 2>/dev/null
systemctl disable cri-docker 2>/dev/null
apt-get purge -y cri-dockerd 2>/dev/null

# 3. Aggressively strip the required sysctls from ANY existing config files
# The Killercoda base image might have these set in standard files (e.g., for Docker)
sed -i '/net.bridge.bridge-nf-call-iptables/d' /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null
sed -i '/net.ipv6.conf.all.forwarding/d' /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null
sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null
sed -i '/net.netfilter.nf_conntrack_max/d' /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null

# Reload sysctl to clear file caches
sysctl --system >/dev/null 2>&1

# 4. Load required kernel modules
modprobe overlay
modprobe br_netfilter
modprobe nf_conntrack

# 5. Force the active memory values to 0 so the user MUST apply them
sysctl -w net.bridge.bridge-nf-call-iptables=0 2>/dev/null
sysctl -w net.ipv6.conf.all.forwarding=0 2>/dev/null
sysctl -w net.ipv4.ip_forward=0 2>/dev/null
sysctl -w net.netfilter.nf_conntrack_max=65536 2>/dev/null

echo "Environment preparation complete."