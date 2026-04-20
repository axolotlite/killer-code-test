#!/bin/bash
# verify.sh - CKA Lab 04: Resource Allocation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

DEPLOY_NAME="wordpress"
NAMESPACE="default"
EXPECTED_REPLICAS="3"

log "INFO" "Running Resource Allocation Validations..."
echo "" | tee -a "$OUTPUT_FILE"

check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE" "" "{.spec.replicas}" "$EXPECTED_REPLICAS"

C_CPU_REQ=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
C_MEM_REQ=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' 2>/dev/null)

I_CPU_REQ=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.initContainers[0].resources.requests.cpu}' 2>/dev/null)
I_MEM_REQ=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.initContainers[0].resources.requests.memory}' 2>/dev/null)

if [ -n "$C_CPU_REQ" ] && [ "$C_CPU_REQ" == "$I_CPU_REQ" ]; then
    log "PASS" "Init CPU requests match Main CPU requests ($C_CPU_REQ)"
    ((PASS_COUNT++))
else
    log "FAIL" "Init CPU requests DO NOT MATCH Main CPU requests"
    ((FAIL_COUNT++))
fi

if [ -n "$C_MEM_REQ" ] && [ "$C_MEM_REQ" == "$I_MEM_REQ" ]; then
    log "PASS" "Init Memory requests match Main Memory requests ($C_MEM_REQ)"
    ((PASS_COUNT++))
else
    log "FAIL" "Init Memory requests DO NOT MATCH Main Memory requests"
    ((FAIL_COUNT++))
fi

# Wait for rollout utility verifies capacity
wait_and_check_rollout deploy "$DEPLOY_NAME" "$NAMESPACE" "10s"

print_summary_and_exit