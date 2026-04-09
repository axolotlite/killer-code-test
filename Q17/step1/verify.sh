#!/bin/bash
# verify.sh - CKA Lab 17: TLS Configuration
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

# 1. Source the utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/utility.sh" ]; then
  source "$SCRIPT_DIR/utility.sh"
else
  echo "[FATAL] utility.sh not found in $SCRIPT_DIR" | tee -a "$OUTPUT_FILE"
  exit 1
fi

# 2. Define target parameters
NAMESPACE="nginx-static"
CM_NAME="nginx-config"
SVC_NAME="nginx-static"
HOST_ENTRY="ckaquestion.k8s.local"
TIMEOUT="15s"

# ==========================================
# EXECUTION BLOCK
# ==========================================

log "INFO" "Running CKA Lab 17: TLS Configuration Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# --- 1. Verify Namespace & Base Resources Exist ---
check_k8s_resource namespace "$NAMESPACE" "" "" "" ""
check_k8s_resource cm "$CM_NAME" "$NAMESPACE" "" "" ""
check_k8s_resource svc "$SVC_NAME" "$NAMESPACE" "" "" ""

# --- 2. Verify the ConfigMap Configuration ---
if kubectl get cm "$CM_NAME" -n "$NAMESPACE" &>/dev/null; then
    CM_DATA=$(kubectl get cm "$CM_NAME" -n "$NAMESPACE" -o jsonpath='{.data}')
    # Extract the ssl_protocols line
    SSL_LINE=$(echo "$CM_DATA" | grep -i "ssl_protocols" || true)
    
    if [ -z "$SSL_LINE" ]; then
        log "FAIL" "Could not find 'ssl_protocols' directive in $CM_NAME ConfigMap."
        ((FAIL_COUNT++))
    else
        if echo "$SSL_LINE" | grep -qi "TLSv1.2"; then
            log "FAIL" "ConfigMap still allows TLSv1.2 in ssl_protocols ($SSL_LINE)."
            ((FAIL_COUNT++))
        elif echo "$SSL_LINE" | grep -qi "TLSv1.3"; then
            log "PASS" "ConfigMap correctly configures TLSv1.3 only."
            ((PASS_COUNT++))
        else
            log "FAIL" "ConfigMap does not configure TLSv1.3 properly ($SSL_LINE)."
            ((FAIL_COUNT++))
        fi
    fi
fi

# --- 3. Verify /etc/hosts Configuration ---
SVC_IP=$(kubectl get svc "$SVC_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
if [ -n "$SVC_IP" ]; then
    # Look for a line in /etc/hosts that starts with the SVC IP and contains the hostname
    if grep -qE "^$SVC_IP[[:space:]]+.*$HOST_ENTRY" /etc/hosts; then
        log "PASS" "Found /etc/hosts entry mapping $HOST_ENTRY to Service IP ($SVC_IP)."
        ((PASS_COUNT++))
    else
        log "FAIL" "Missing or incorrect /etc/hosts entry for $HOST_ENTRY mapping to $SVC_IP."
        ((FAIL_COUNT++))
    fi
fi

# --- 4. Verify Deployment Restart / Status ---
# Dynamically find the deployment name in the namespace
DEPLOY_NAME=$(kubectl get deploy -n "$NAMESPACE" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$DEPLOY_NAME" ]; then
    log "FAIL" "No Deployment found in namespace '$NAMESPACE'."
    ((FAIL_COUNT++))
else
    log "INFO" "Waiting up to $TIMEOUT for Deployment '$DEPLOY_NAME' to be Ready (Restart Check)..."
    kubectl rollout status deploy "$DEPLOY_NAME" -n "$NAMESPACE" --timeout=$TIMEOUT >/dev/null 2>&1 || true

    READY_REPLICAS=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}')
    EXPECTED_REPLICAS=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')

    if [ "$READY_REPLICAS" == "$EXPECTED_REPLICAS" ] && [ -n "$EXPECTED_REPLICAS" ]; then
        log "PASS" "Deployment '$DEPLOY_NAME' is fully ready."
        ((PASS_COUNT++))
    else
        log "FAIL" "Deployment '$DEPLOY_NAME' is not ready (Ready: ${READY_REPLICAS:-0}/${EXPECTED_REPLICAS:-0}). Did the restart fail due to a bad config?"
        ((FAIL_COUNT++))
    fi
fi

# --- 5. Verify TLS Connectivity (Runtime check via cURL) ---
log "INFO" "Executing cURL TLS connectivity tests..."

# Test 1: TLS 1.2 (Should Fail)
if curl -sk --tls-max 1.2 "https://$HOST_ENTRY" --connect-timeout 3 &>/dev/null; then
    log "FAIL" "TLS 1.2 connection succeeded (Expected it to be disabled)."
    ((FAIL_COUNT++))
else
    log "PASS" "TLS 1.2 connection failed as expected."
    ((PASS_COUNT++))
fi

# Test 2: TLS 1.3 (Should Succeed)
if curl -sk --tlsv1.3 --tls-max 1.3 "https://$HOST_ENTRY" --connect-timeout 3 &>/dev/null; then
    log "PASS" "TLS 1.3 connection succeeded."
    ((PASS_COUNT++))
else
    log "FAIL" "TLS 1.3 connection failed (Ensure the deployment is running and TLSv1.3 is active)."
    ((FAIL_COUNT++))
fi

# ==========================================
# RESULTS SUMMARY
# ==========================================

print_summary_and_exit