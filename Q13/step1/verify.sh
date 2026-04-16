#!/bin/bash
# verify.sh - CKA Lab 13: Network Policy Selection
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

log "INFO" "Running Network Policy Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# Verifying correct policies were selected / deleted
check_k8s_resource_absent networkpolicy "policy-1" "backend"
check_k8s_resource_absent networkpolicy "policy-2" "backend"
check_k8s_resource networkpolicy "policy-3" "backend" "" "{.spec.ingress[0].ports[0].port}" "80"

# Allow Test
FRONTEND_POD=$(kubectl get pod -n frontend -l app=frontend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$FRONTEND_POD" ]; then
    check_pod_curl "$FRONTEND_POD" "frontend" "http://backend-service.backend.svc.cluster.local" "200" 5
else
    log "FAIL" "Cannot run curl test: frontend pod is missing."
    ((FAIL_COUNT++))
fi

print_summary_and_exit