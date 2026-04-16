#!/bin/bash
# verify.sh - CKA Lab 17: TLS Configuration
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

NAMESPACE="nginx-static"
CM_NAME="nginx-config"
SVC_NAME="nginx-static"
HOST_ENTRY="ckaquestion.k8s.local"

log "INFO" "Running TLS Validations..."
echo "" | tee -a "$OUTPUT_FILE"

check_k8s_resource_contains cm "$CM_NAME" "$NAMESPACE" "{.data}" "TLSv1.3"
# Verify it does NOT contain v1.2
if kubectl get cm "$CM_NAME" -n "$NAMESPACE" -o jsonpath='{.data}' 2>/dev/null | grep -qi "TLSv1.2"; then
    log "FAIL" "ConfigMap still contains TLSv1.2."
    ((FAIL_COUNT++))
else
    log "PASS" "ConfigMap omits TLSv1.2 as requested."
    ((PASS_COUNT++))
fi

# Verify Hosts File
SVC_IP=$(kubectl get svc "$SVC_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
if [ -n "$SVC_IP" ]; then
    check_local_file "/etc/hosts" "^$SVC_IP[[:space:]]+.*$HOST_ENTRY"
else
    log "FAIL" "Could not check /etc/hosts, missing Service IP."
    ((FAIL_COUNT++))
fi

# Verify rollout logic
DEPLOY_NAME=$(kubectl get deploy -n "$NAMESPACE" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$DEPLOY_NAME" ]; then
    wait_and_check_rollout deploy "$DEPLOY_NAME" "$NAMESPACE" "15s"
fi

# Test 1: TLS 1.2 (Should Fail/Timeout -> Returns 000000)
check_http_status "https://$HOST_ENTRY" "000000" 1 1 "-k --tls-max 1.2"

# Test 2: TLS 1.3 (Should Succeed -> Returns 200)
check_http_status "https://$HOST_ENTRY" "200" 3 2 "-k --tlsv1.3 --tls-max 1.3"

print_summary_and_exit