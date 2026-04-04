#!/bin/bash
# verify.sh - CKA Lab 04: Resource Allocation
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
DEPLOY_NAME="wordpress"
NAMESPACE="default" # Update if the lab specifies a different namespace
EXPECTED_REPLICAS="3"
TIMEOUT="5s"

# ==========================================
# EXECUTION BLOCK
# ==========================================

log "INFO" "Running CKA Lab 04: Resource Allocation Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# 1. Verify the Deployment exists
check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE" "" "" ""

if ! kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" &>/dev/null; then
    log "FAIL" "Deployment '$DEPLOY_NAME' does not exist. Halting further checks."
    ((FAIL_COUNT++))
    print_summary_and_exit
fi

# 2. Verify Replicas are scaled back up to 3
check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE" "" "{.spec.replicas}" "$EXPECTED_REPLICAS"

# 3. Extract Resources for Main Container (Assuming index 0)
C_CPU_REQ=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')
C_MEM_REQ=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')
C_CPU_LIM=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}')
C_MEM_LIM=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}')

# 4. Extract Resources for Init Container (Assuming index 0)
I_CPU_REQ=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.initContainers[0].resources.requests.cpu}')
I_MEM_REQ=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.initContainers[0].resources.requests.memory}')
I_CPU_LIM=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.initContainers[0].resources.limits.cpu}')
I_MEM_LIM=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.initContainers[0].resources.limits.memory}')

# --- Validation: Are resources configured at all? ---
if [ -z "$C_CPU_REQ" ] || [ -z "$C_MEM_REQ" ]; then
    log "FAIL" "Main container is missing CPU or Memory requests."
    ((FAIL_COUNT++))
else
    log "PASS" "Main container has resource requests defined (CPU: $C_CPU_REQ, Mem: $C_MEM_REQ)"
    ((PASS_COUNT++))
fi

# --- Validation: Init Container vs Main Container Equality ---
if [ -z "$I_CPU_REQ" ]; then
    log "FAIL" "Init container is missing resource requests."
    ((FAIL_COUNT++))
else
    # Check CPU Requests
    if [ "$C_CPU_REQ" == "$I_CPU_REQ" ]; then
        log "PASS" "Init CPU requests match Main CPU requests ($C_CPU_REQ)"
        ((PASS_COUNT++))
    else
        log "FAIL" "Init CPU requests ($I_CPU_REQ) DO NOT MATCH Main CPU requests ($C_CPU_REQ)"
        ((FAIL_COUNT++))
    fi

    # Check Memory Requests
    if [ "$C_MEM_REQ" == "$I_MEM_REQ" ]; then
        log "PASS" "Init Memory requests match Main Memory requests ($C_MEM_REQ)"
        ((PASS_COUNT++))
    else
        log "FAIL" "Init Memory requests ($I_MEM_REQ) DO NOT MATCH Main Memory requests ($C_MEM_REQ)"
        ((FAIL_COUNT++))
    fi
    
    # Check CPU Limits (If they set limits)
    if [ -n "$C_CPU_LIM" ] && [ "$C_CPU_LIM" == "$I_CPU_LIM" ]; then
        log "PASS" "Init CPU limits match Main CPU limits ($C_CPU_LIM)"
        ((PASS_COUNT++))
    elif [ "$C_CPU_LIM" != "$I_CPU_LIM" ]; then
        log "FAIL" "Init CPU limits ($I_CPU_LIM) DO NOT MATCH Main CPU limits ($C_CPU_LIM)"
        ((FAIL_COUNT++))
    fi
fi

# --- Validation: Safety Margin (Runtime Check) ---
# If the pods requested too much (e.g. 33.3% exactly leaving no room for kubelet), 
# the 3rd pod will be stuck in "Pending". If all 3 are Ready, the margin is valid.

log "INFO" "Waiting up to $TIMEOUT for Pods to be scheduled and Running..."
kubectl rollout status deploy "$DEPLOY_NAME" -n "$NAMESPACE" --timeout=$TIMEOUT >/dev/null 2>&1 || true

READY_REPLICAS=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}')

if [ "$READY_REPLICAS" == "$EXPECTED_REPLICAS" ]; then
    log "PASS" "All $EXPECTED_REPLICAS Pods are Ready. (Proof of sufficient node capacity / safety margin)"
    ((PASS_COUNT++))
else
    log "FAIL" "Expected $EXPECTED_REPLICAS Ready pods, but found '${READY_REPLICAS:-0}'. Check for 'Pending' pods due to Insufficient CPU/Memory."
    
    # Grab the reason why pods might be pending to give the user a hint
    PENDING_POD=$(kubectl get pods -n "$NAMESPACE" -l "app=$DEPLOY_NAME" --field-selector status.phase=Pending -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [ -n "$PENDING_POD" ]; then
        log "INFO" "Pod $PENDING_POD is Pending. Reason:"
        kubectl describe pod "$PENDING_POD" -n "$NAMESPACE" | grep -A 2 "FailedScheduling" | tee -a "$OUTPUT_FILE"
    fi
    ((FAIL_COUNT++))
fi

# ==========================================
# RESULTS SUMMARY
# ==========================================

print_summary_and_exit