#!/bin/bash
# verify.sh - Step 5: PVC Mounted to Database StatefulSet
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../assets/utility.sh"

NS="default"

log "INFO" "Validating Step 5: PVC Attached to Database..."
echo "" | tee -a "$OUTPUT_FILE"

check_k8s_resource statefulset "store-db" "$NS" "" '{.spec.template.spec.volumes[0].persistentVolumeClaim.claimName}' "db-data-pvc"
check_k8s_resource statefulset "store-db" "$NS" "" '{.spec.template.spec.containers[0].volumeMounts[0].mountPath}' "/var/lib/postgresql/data"

print_summary_and_exit
