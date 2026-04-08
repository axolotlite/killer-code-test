#!/bin/bash
# verify.sh - CKA Lab 13: Network Policy Selection
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

log "INFO" "Running CKA Lab 13: Network Policy Selection Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# --- Task 1 & 2 & 3: Validate Correct Policy Application ---

# policy-1 is wildly permissive (podSelector: {}, ingress: [{}])
if kubectl get networkpolicy policy-1 -n backend &>/dev/null; then
    log "FAIL" "NetworkPolicy 'policy-1' was applied. This is an 'allow-all' policy and is NOT the least permissive."
    ((FAIL_COUNT++))
else
    log "PASS" "NetworkPolicy 'policy-1' was correctly rejected/ignored."
    ((PASS_COUNT++))
fi

# policy-2 is less permissive but still allows an entire /16 subnet.
if kubectl get networkpolicy policy-2 -n backend &>/dev/null; then
    log "FAIL" "NetworkPolicy 'policy-2' was applied. It allows a full 172.16.0.0/16 subnet, which is not the least permissive."
    ((FAIL_COUNT++))
else
    log "PASS" "NetworkPolicy 'policy-2' was correctly rejected/ignored."
    ((PASS_COUNT++))
fi

# policy-3 is the least permissive (restricts exclusively to frontend namespace / frontend pods).
if ! kubectl get networkpolicy policy-3 -n backend &>/dev/null; then
    log "FAIL" "NetworkPolicy 'policy-3' is NOT applied. This was the correct, least permissive policy."
    ((FAIL_COUNT++))
    print_summary_and_exit
else
    log "PASS" "NetworkPolicy 'policy-3' was successfully applied to the 'backend' namespace."
    ((PASS_COUNT++))
fi

# Verify the port rule on the applied policy explicitly checks for port 80
check_k8s_resource networkpolicy "policy-3" "backend" "" "{.spec.ingress[0].ports[0].port}" "80"

# Give the CNI a moment to enforce the rules before testing traffic
sleep 2

# --- Task 4: Verify Live Traffic (The HTTP 200 Check) ---

FRONTEND_POD=$(kubectl get pod -n frontend -l app=frontend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
BACKEND_SVC="backend-service.backend.svc.cluster.local"

if [ -z "$FRONTEND_POD" ]; then
    log "FAIL" "Could not locate the frontend pod to test allowed traffic."
    ((FAIL_COUNT++))
else
    log "INFO" "Executing curl request from Authorized Frontend Pod -> Backend Service..."
    
    # We strictly check for HTTP code 200
    HTTP_CODE=$(kubectl exec -n frontend "$FRONTEND_POD" -- curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://$BACKEND_SVC || echo "000")
    
    if [ "$HTTP_CODE" == "200" ]; then
        log "PASS" "Frontend successfully reached the backend. Strict HTTP code 200 received!"
        ((PASS_COUNT++))
    else
        log "FAIL" "Frontend FAILED to reach backend. Expected HTTP 200, but got: $HTTP_CODE."
        ((FAIL_COUNT++))
    fi
fi

# --- Task 5: Verify Blocked Traffic (Ensuring the policy actually protects the backend) ---

log "INFO" "Executing curl request from an Unauthorized Pod in the 'default' namespace..."
# Spin up a temporary pod in default namespace to attempt a connection, expect a timeout/failure (000)
BLOCKED_HTTP_CODE=$(kubectl run -q net-test-pod-$(date +%s) --image=curlimages/curl --restart=Never -n default --rm -i -- curl -s -o /dev/null -w "%{http_code}" --max-time 3 http://$BACKEND_SVC 2>/dev/null || echo "000")

if [ "$BLOCKED_HTTP_CODE" == "200" ]; then
    log "FAIL" "Traffic from the unauthorized 'default' namespace received HTTP 200. The NetworkPolicy is too permissive!"
    ((FAIL_COUNT++))
elif [ "$BLOCKED_HTTP_CODE" == "000" ]; then
    log "PASS" "Traffic from the unauthorized namespace timed out correctly. The NetworkPolicy effectively isolates the backend."
    ((PASS_COUNT++))
else
    log "INFO" "Traffic was blocked but returned an unexpected HTTP code: $BLOCKED_HTTP_CODE (Expected 000 timeout)."
    ((PASS_COUNT++)) # Technically still successfully blocked from seeing the app
fi

# ==========================================
# RESULTS SUMMARY
# ==========================================

print_summary_and_exit