#!/bin/bash
# verify.sh - Validation for CKA Lab 09: cri-dockerd Installation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

# 1. Source the utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/utility.sh" ]; then
  source "$SCRIPT_DIR/utility.sh"
else
  echo "[FATAL] utility.sh not found in $SCRIPT_DIR" | tee -a "$OUTPUT_FILE"
  exit 1
fi

# ==========================================
# EXECUTION BLOCK
# ==========================================

log "INFO" "Running cri-dockerd & sysctl Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# ---------------------------------------------------------
# Task 1: Check if the Debian package is installed
# ---------------------------------------------------------
if dpkg-query -W -f='${Status}' cri-dockerd 2>/dev/null | grep -q "install ok installed"; then
  log "PASS" "cri-dockerd package is installed"
  ((PASS_COUNT++))
else
  log "FAIL" "cri-dockerd package is NOT installed"
  ((FAIL_COUNT++))
fi

# ---------------------------------------------------------
# Task 2: Check if cri-dockerd service is enabled and active
# ---------------------------------------------------------
if systemctl is-enabled --quiet cri-dockerd 2>/dev/null; then
  log "PASS" "cri-dockerd service is enabled"
  ((PASS_COUNT++))
else
  log "FAIL" "cri-dockerd service is NOT enabled"
  ((FAIL_COUNT++))
fi

if systemctl is-active --quiet cri-dockerd 2>/dev/null; then
  log "PASS" "cri-dockerd service is running (active)"
  ((PASS_COUNT++))
else
  log "FAIL" "cri-dockerd service is NOT running"
  ((FAIL_COUNT++))
fi

# ---------------------------------------------------------
# Task 3: Check sysctl parameters (Active & Persistent)
# ---------------------------------------------------------
check_sysctl_param() {
  local param="$1"
  local expected="$2"
  
  # Check 1: Is it currently applied in memory?
  local actual
  actual=$(sysctl -n "$param" 2>/dev/null)
  if [ "$actual" == "$expected" ]; then
    log "PASS" "sysctl $param is actively applied in memory"
    ((PASS_COUNT++))
  else
    log "FAIL" "sysctl $param is NOT actively applied (expected: $expected, actual: $actual)"
    ((FAIL_COUNT++))
  fi
  
  # Check 2: Is it persistent? (Checking /etc/sysctl.conf and /etc/sysctl.d/*.conf)
  # Uses a regex to tolerate spaces (e.g., 'net.ipv4.ip_forward = 1')
  if grep -hRE "^[[:space:]]*${param}[[:space:]]*=[[:space:]]*${expected}" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null | grep -q .; then
    log "PASS" "sysctl $param is configured persistently"
    ((PASS_COUNT++))
  else
    log "FAIL" "sysctl $param is NOT configured persistently in /etc/sysctl.conf or /etc/sysctl.d/*.conf"
    ((FAIL_COUNT++))
  fi
}

check_sysctl_param "net.bridge.bridge-nf-call-iptables" "1"
check_sysctl_param "net.ipv6.conf.all.forwarding" "1"
check_sysctl_param "net.ipv4.ip_forward" "1"
check_sysctl_param "net.netfilter.nf_conntrack_max" "131072"

# ==========================================
# RESULTS SUMMARY
# ==========================================
print_summary_and_exit