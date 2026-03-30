#!/bin/bash
# verify.sh - ArgoCD Helm Installation Validation
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

log "INFO" "Running ArgoCD Helm Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# ---------------------------------------------------------
# Task 1: Add the official ArgoCD Helm repository
# ---------------------------------------------------------
HELM_REPO_NAME="argocd"
HELM_REPO_URL="https://argoproj.github.io/argo-helm"

# Use helm repo list and regex to verify the name and URL map correctly
if helm repo list 2>/dev/null | grep -qE "^${HELM_REPO_NAME}\s+${HELM_REPO_URL}/?\s*"; then
  log "PASS" "Helm repository '${HELM_REPO_NAME}' is configured with the correct URL"
  ((PASS_COUNT++))
else
  log "FAIL" "Helm repository '${HELM_REPO_NAME}' is missing or URL is incorrect"
  ((FAIL_COUNT++))
fi

# ---------------------------------------------------------
# Task 2: Create a namespace called `argocd`
# ---------------------------------------------------------
# Uses the built-in function from utility.sh to check cluster state
check_k8s_resource ns "argocd" "" "" "" ""

# ---------------------------------------------------------
# Task 3: Generate a Helm template
# ---------------------------------------------------------
MANIFEST_FILE="/root/argo-helm.yaml"
EXPECTED_VERSION="9.1.10"
EXPECTED_NS="argocd"

if [ -f "$MANIFEST_FILE" ]; then
  log "PASS" "Generated YAML manifest $MANIFEST_FILE exists"
  ((PASS_COUNT++))

  # Check 3a: Chart Version (Helm injects labels like 'helm.sh/chart: argo-cd-9.1.10')
  if grep -q "argo-cd-${EXPECTED_VERSION}\|chart:.*${EXPECTED_VERSION}" "$MANIFEST_FILE"; then
    log "PASS" "Manifest uses the correct chart version ($EXPECTED_VERSION)"
    ((PASS_COUNT++))
  else
    log "FAIL" "Manifest does NOT appear to use chart version $EXPECTED_VERSION"
    ((FAIL_COUNT++))
  fi

  # Check 3b: Namespace scoping
  if grep -q "namespace: ${EXPECTED_NS}" "$MANIFEST_FILE"; then
    log "PASS" "Manifest specifies the correct namespace ($EXPECTED_NS)"
    ((PASS_COUNT++))
  else
    log "FAIL" "Manifest is NOT correctly scoped to the '$EXPECTED_NS' namespace"
    ((FAIL_COUNT++))
  fi

  # Check 3c: Omission of CRDs
  # If '--skip-crds' was used properly during helm template, no CRD kinds should exist.
  if grep -q "kind: CustomResourceDefinition" "$MANIFEST_FILE"; then
    log "FAIL" "Manifest contains CRDs (they should be omitted)"
    ((FAIL_COUNT++))
  else
    log "PASS" "Manifest correctly omits CustomResourceDefinitions"
    ((PASS_COUNT++))
  fi

else
  log "FAIL" "Manifest file $MANIFEST_FILE does NOT exist"
  ((FAIL_COUNT++))
  
  # Log sub-failures so the user knows exactly what they missed
  log "FAIL" "Skipping chart version check because file is missing"
  ((FAIL_COUNT++))
  log "FAIL" "Skipping namespace scope check because file is missing"
  ((FAIL_COUNT++))
  log "FAIL" "Skipping CRD omission check because file is missing"
  ((FAIL_COUNT++))
fi

# ==========================================
# RESULTS SUMMARY
# ==========================================

# Print kube-bench style matrix and exit 0 or 1
print_summary_and_exit