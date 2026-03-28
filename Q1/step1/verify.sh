#!/bin/bash
# postgres-validate.sh - Postgres PVC/PV/Deployment Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

# 1. Source the utility library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/utility.sh" ]; then
  source "$SCRIPT_DIR/utility.sh"
else
  echo "[FATAL] utility.sh not found in $SCRIPT_DIR" | tee -a "$OUTPUT_FILE"
  pwd | tee -a "$OUTPUT_FILE"
  ls | tee -a "$OUTPUT_FILE"
  exit 1
fi

# 2. Define expected state
NS="postgres"
DEPLOYMENT="postgres"
PVC="postgres"
PV_NAME="postgres-pv"
PV_SIZE="250Mi"
PV_ACCESS="ReadWriteOnce"

# ==========================================
# EXECUTION BLOCK
# ==========================================

log "INFO" "Running Postgres Deployment and Storage Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# 1. Namespace existence
if check_k8s_resource namespace "$NS"; then
  log "PASS" "Namespace $NS exists"
else
  log "FAIL" "Namespace $NS is missing"
  ((FAIL_COUNT++))
fi

# 2. Deployment existence
if check_k8s_resource deployment "$DEPLOYMENT" "$NS"; then
  log "PASS" "Deployment $DEPLOYMENT exists in $NS"
else
  log "FAIL" "Deployment $DEPLOYMENT doesn't exist in $NS"
  ((FAIL_COUNT++))
fi

# 3. PV access mode
check_k8s_resource pv "$PV_NAME" "$NS" "" '{.spec.accessModes[0]}' "$PV_ACCESS"

# 4. PV size
check_k8s_resource pv "$PV_NAME" "$NS" "" '{.spec.capacity.storage}' "$PV_SIZE"

# 5. PVC size
check_k8s_resource pvc "$PVC" "$NS" "" '{.spec.resources.requests.storage}' "$PV_SIZE"

# 6. PVC bound PV
check_k8s_resource pvc "$PVC" "$NS" "" '{.spec.volumeName}' "$PV_NAME"

# ==========================================
# RESULTS SUMMARY
# ==========================================

print_summary_and_exit