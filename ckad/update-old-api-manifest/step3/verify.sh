#!/bin/bash
# verify.sh - Step 3: PSP Removal & RBAC Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

log "INFO" "Running Step 3 — PSP Removal & RBAC Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# Task 1: PodSecurityPolicy must be removed from the manifest file
RBAC_FILE="$HOME/deploy/rbac-psp.yaml"
if [ -f "$RBAC_FILE" ]; then
  if grep -qi "PodSecurityPolicy" "$RBAC_FILE"; then
    log "FAIL" "~/deploy/rbac-psp.yaml still contains PodSecurityPolicy (must be removed)"
    ((FAIL_COUNT++))
  else
    log "PASS" "PodSecurityPolicy has been removed from ~/deploy/rbac-psp.yaml"
    ((PASS_COUNT++))
  fi

  if grep -q "policy/v1beta1" "$RBAC_FILE"; then
    log "FAIL" "~/deploy/rbac-psp.yaml still references policy/v1beta1"
    ((FAIL_COUNT++))
  else
    log "PASS" "No policy/v1beta1 references remain in ~/deploy/rbac-psp.yaml"
    ((PASS_COUNT++))
  fi
else
  log "FAIL" "~/deploy/rbac-psp.yaml not found"
  ((FAIL_COUNT++))
fi

# Task 2: RBAC resources use correct apiVersion
check_k8s_resource clusterrole "garland-admin" "" "" "" ""

CR_API=$(kubectl get clusterrole garland-admin -o jsonpath='{.apiVersion}' 2>/dev/null)
if [ "$CR_API" == "rbac.authorization.k8s.io/v1" ]; then
  log "PASS" "ClusterRole garland-admin uses apiVersion rbac.authorization.k8s.io/v1"
  ((PASS_COUNT++))
else
  log "FAIL" "ClusterRole garland-admin apiVersion is '$CR_API', expected 'rbac.authorization.k8s.io/v1'"
  ((FAIL_COUNT++))
fi

check_k8s_resource clusterrolebinding "garland-admin-binding" "" "" "" ""

CRB_API=$(kubectl get clusterrolebinding garland-admin-binding -o jsonpath='{.apiVersion}' 2>/dev/null)
if [ "$CRB_API" == "rbac.authorization.k8s.io/v1" ]; then
  log "PASS" "ClusterRoleBinding garland-admin-binding uses apiVersion rbac.authorization.k8s.io/v1"
  ((PASS_COUNT++))
else
  log "FAIL" "ClusterRoleBinding garland-admin-binding apiVersion is '$CRB_API', expected 'rbac.authorization.k8s.io/v1'"
  ((FAIL_COUNT++))
fi

# Verify ClusterRoleBinding references the right ServiceAccount
check_k8s_resource clusterrolebinding "garland-admin-binding" "" "" '{.subjects[0].namespace}' "garland"
check_k8s_resource clusterrolebinding "garland-admin-binding" "" "" '{.roleRef.name}' "garland-admin"

print_summary_and_exit
