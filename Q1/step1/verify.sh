#!/bin/bash
# postgres-validate.sh - Postgres Deployment and Storage Validation
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
check_k8s_resource namespace "$NS"

# 3. PV access mode (cluster-scoped, no namespace)
check_k8s_resource pv "$PV_NAME" "" "" '{.spec.accessModes[0]}' "$PV_ACCESS"

# 4. PV size
check_k8s_resource pv "$PV_NAME" "" "" '{.spec.capacity.storage}' "$PV_SIZE"

# 5. PVC size
check_k8s_resource pvc "$PVC" "$NS" "" '{.spec.resources.requests.storage}' "$PV_SIZE"

# 6. PVC bound PV
check_k8s_resource pvc "$PVC" "$NS" "" '{.spec.volumeName}' "$PV_NAME"

# 7. check if the deployment exists
check_k8s_resource deployment "$DEPLOYMENT" "$NS"

# 8. check if the pv is added to volumes
check_k8s_resource deployment "$DEPLOYMENT" "$NS" "" "{.spec.template.spec.volumes[0].persistentVolumeClaim.claimName}" $PVC
# 9. Check if the pvc is mounted correctly
check_k8s_resource deployment "$DEPLOYMENT" "$NS" "" "{.spec.template.spec.containers[0].volumeMounts[0].mountPath}" "/var/lib/postgresql/data"

# ==========================================
# RESULTS SUMMARY
# ==========================================

print_summary_and_exit