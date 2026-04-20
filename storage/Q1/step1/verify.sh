#!/bin/bash
# verify.sh - Postgres Deployment and Storage Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

NS="postgres"
DEPLOYMENT="postgres"
PVC="postgres-pvc"
PV_NAME="postgres-pv"
PV_SIZE="250Mi"
PV_ACCESS="ReadWriteOnce"
MOUNT_PATH="/var/lib/postgresql/data"

log "INFO" "Running Postgres Validations..."
echo "" | tee -a "$OUTPUT_FILE"

check_k8s_resource namespace "$NS"
check_k8s_resource pv "$PV_NAME" "" "" '{.spec.accessModes[0]}' "$PV_ACCESS"
check_k8s_resource pv "$PV_NAME" "" "" '{.spec.capacity.storage}' "$PV_SIZE"
check_k8s_resource pvc "$PVC" "$NS" "" '{.spec.resources.requests.storage}' "$PV_SIZE"
check_k8s_resource pvc "$PVC" "$NS" "" '{.spec.volumeName}' "$PV_NAME"

check_k8s_resource deployment "$DEPLOYMENT" "$NS"
check_k8s_resource deployment "$DEPLOYMENT" "$NS" "" "{.spec.template.spec.volumes[0].persistentVolumeClaim.claimName}" $PVC
check_k8s_resource deployment "$DEPLOYMENT" "$NS" "" "{.spec.template.spec.containers[0].volumeMounts[0].mountPath}" $MOUNT_PATH

print_summary_and_exit