#!/bin/bash
# verify.sh - CKA Lab 03: Sidecar Container Pattern
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

DEPLOY_NAME="nginx"
NAMESPACE="nginx"
SIDECAR_NAME="sidecar"
SIDECAR_IMAGE="busybox:stable"
EXPECTED_MOUNT_PATH="/var/log"

log "INFO" "Running Sidecar Pattern Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# Deployment exists
check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE"

# Sidecar config
check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE" "" "{.spec.template.spec.containers[?(@.name==\"$SIDECAR_NAME\")].name}" "$SIDECAR_NAME"
check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE" "" "{.spec.template.spec.containers[?(@.name==\"$SIDECAR_NAME\")].image}" "$SIDECAR_IMAGE"

# Sidecar command checking via contains utility
check_k8s_resource_contains deploy "$DEPLOY_NAME" "$NAMESPACE" "{.spec.template.spec.containers[?(@.name==\"$SIDECAR_NAME\")].command[*]} {.spec.template.spec.containers[?(@.name==\"$SIDECAR_NAME\")].args[*]}" "tail -f /var/log/nginx/access.log"

# Verify Shared Volume Mounts
sidecar_vol_name=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath="{.spec.template.spec.containers[?(@.name==\"$SIDECAR_NAME\")].volumeMounts[?(@.mountPath==\"$EXPECTED_MOUNT_PATH\")].name}" 2>/dev/null)

if [ -n "$sidecar_vol_name" ]; then
    log "PASS" "Sidecar mounted a volume at '$EXPECTED_MOUNT_PATH' (Vol: '$sidecar_vol_name')"
    ((PASS_COUNT++))
    check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE" "" "{.spec.template.spec.containers[?(@.name==\"nginx\")].volumeMounts[?(@.name==\"$sidecar_vol_name\")].mountPath}" ""
else
    log "FAIL" "Sidecar container does NOT have a volume mounted at '$EXPECTED_MOUNT_PATH'"
    ((FAIL_COUNT++))
fi

print_summary_and_exit