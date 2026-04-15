#!/bin/bash
# verify.sh - ArgoCD Helm Installation Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

log "INFO" "Running ArgoCD Helm Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# Task 1: Helm Repo check
if helm repo list 2>/dev/null | grep -qE "^argocd\s+https://argoproj.github.io/argo-helm/?\s*"; then
  log "PASS" "Helm repository 'argocd' is configured correctly."
  ((PASS_COUNT++))
else
  log "FAIL" "Helm repository 'argocd' is missing or incorrect."
  ((FAIL_COUNT++))
fi

# Task 2: Namespace
check_k8s_resource ns "argocd" "" "" "" ""

# Task 3: Manifest Checks (using new check_local_file utility)
MANIFEST_FILE="/root/argo-helm.yaml"

# Ensure the file exists
check_local_file "$MANIFEST_FILE" ""

# 3a: Chart Version
check_local_file "$MANIFEST_FILE" "argo-cd-9.1.10\|chart:.*9.1.10"
# 3b: Namespace scoping
check_local_file "$MANIFEST_FILE" "namespace: argocd"

# 3c: Omission of CRDs
if [ -f "$MANIFEST_FILE" ]; then
  if grep -q "kind: CustomResourceDefinition" "$MANIFEST_FILE"; then
    log "FAIL" "Manifest contains CRDs (they should be omitted)."
    ((FAIL_COUNT++))
  else
    log "PASS" "Manifest correctly omits CustomResourceDefinitions."
    ((PASS_COUNT++))
  fi
else
  log "FAIL" "Cannot check CRD omission, $MANIFEST_FILE is missing."
  ((FAIL_COUNT++))
fi

print_summary_and_exit