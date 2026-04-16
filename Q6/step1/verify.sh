#!/bin/bash
# verify.sh - Custom Resource Definitions (CRDs) Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

log "INFO" "Running CRD Lab Validations..."
echo "" | tee -a "$OUTPUT_FILE"

RESOURCES_FILE="/root/resources.yaml"
check_local_file "$RESOURCES_FILE" ""

if [ -f "$RESOURCES_FILE" ]; then
  CLUSTER_CRDS=$(kubectl get crd -o custom-columns=NAME:.metadata.name --no-headers | grep "cert-manager")
  MISSING_CRDS=""
  for crd in $CLUSTER_CRDS; do
    if ! grep -qF "$crd" "$RESOURCES_FILE"; then MISSING_CRDS="$MISSING_CRDS $crd"; fi
  done

  if [ -z "$MISSING_CRDS" ] && [ -n "$CLUSTER_CRDS" ]; then
    log "PASS" "File contains all cert-manager CRDs."
    ((PASS_COUNT++))
  else
    log "FAIL" "File is missing cert-manager CRDs: ${MISSING_CRDS}"
    ((FAIL_COUNT++))
  fi
fi

SUBJECT_FILE="/root/subject.yaml"
check_local_file "$SUBJECT_FILE" "KIND:\s*Certificate"
check_local_file "$SUBJECT_FILE" "FIELD:\s*subject"

URIS_FILE="/root/uris.yaml"
check_local_file "$URIS_FILE" "KIND:\s*Certificate"
check_local_file "$URIS_FILE" "FIELD:\s*uris"

print_summary_and_exit