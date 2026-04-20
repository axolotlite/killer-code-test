#!/bin/bash
# verify.sh - Validation for CKA Lab 09: cri-dockerd Installation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

log "INFO" "Running cri-dockerd & sysctl Validations..."
echo "" | tee -a "$OUTPUT_FILE"

check_deb_package "cri-dockerd"
check_systemd_service "cri-docker"

check_sysctl_active "net.bridge.bridge-nf-call-iptables" "1"
check_sysctl_active "net.ipv6.conf.all.forwarding" "1"
check_sysctl_active "net.ipv4.ip_forward" "1"
check_sysctl_active "net.netfilter.nf_conntrack_max" "131072"

# Persistent check via file content
if grep -hRE "^[[:space:]]*net.bridge.bridge-nf-call-iptables[[:space:]]*=[[:space:]]*1" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null | grep -q .; then
  log "PASS" "sysctl parameters are configured persistently."
  ((PASS_COUNT++))
else
  log "FAIL" "sysctl parameters are NOT configured persistently."
  ((FAIL_COUNT++))
fi

print_summary_and_exit