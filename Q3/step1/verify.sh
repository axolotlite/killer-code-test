#!/bin/bash
# verify.sh - CKA Lab 03: Sidecar Container Pattern
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
DEPLOY_NAME="nginx"
NAMESPACE="nginx"
SIDECAR_NAME="sidecar"
SIDECAR_IMAGE="busybox:stable"
EXPECTED_MOUNT_PATH="/var/log"

# ==========================================
# EXECUTION BLOCK
# ==========================================

log "INFO" "Running CKA Lab 03: Sidecar Pattern Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# 1. Verify the Deployment still exists
check_k8s_resource deploy "$DEPLOY_NAME" "$NAMESPACE" "" "" ""

# Halt further checks if deployment doesn't even exist
if ! kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" &>/dev/null; then
    log "FAIL" "Deployment '$DEPLOY_NAME' does not exist. Halting further checks."
    ((FAIL_COUNT++))
    print_summary_and_exit
fi

# 2. Verify Sidecar Container Existence
sidecar_exists=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath="{.spec.template.spec.containers[?(@.name==\"$SIDECAR_NAME\")].name}" 2>/dev/null)
if [ "$sidecar_exists" == "$SIDECAR_NAME" ]; then
    log "PASS" "Container '$SIDECAR_NAME' exists in deployment '$DEPLOY_NAME'"
    ((PASS_COUNT++))
else
    log "FAIL" "Container '$SIDECAR_NAME' not found in deployment '$DEPLOY_NAME'"
    ((FAIL_COUNT++))
fi

# 3. Verify Sidecar Image
sidecar_image=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath="{.spec.template.spec.containers[?(@.name==\"$SIDECAR_NAME\")].image}" 2>/dev/null)
if [ "$sidecar_image" == "$SIDECAR_IMAGE" ]; then
    log "PASS" "Sidecar container uses the correct image: '$SIDECAR_IMAGE'"
    ((PASS_COUNT++))
else
    log "FAIL" "Sidecar container image is '$sidecar_image', expected '$SIDECAR_IMAGE'"
    ((FAIL_COUNT++))
fi

# 4. Verify Sidecar Command (Merging command and args for flexible validation)
sidecar_cmd=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath="{.spec.template.spec.containers[?(@.name==\"$SIDECAR_NAME\")].command[*]}" 2>/dev/null)
sidecar_args=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath="{.spec.template.spec.containers[?(@.name==\"$SIDECAR_NAME\")].args[*]}" 2>/dev/null)
full_cmd="$sidecar_cmd $sidecar_args"

if [[ "$full_cmd" == *"/bin/sh"* && "$full_cmd" == *"tail -f /var/log/nginx/access.log"* ]]; then
    log "PASS" "Sidecar container has the correct tail command"
    ((PASS_COUNT++))
else
    log "FAIL" "Sidecar container command incorrect or missing. Found: '$full_cmd'"
    ((FAIL_COUNT++))
fi

# 5. Verify Shared Volume Mounts
# Find the volume name mounted at /var/log inside the sidecar
sidecar_vol_name=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath="{.spec.template.spec.containers[?(@.name==\"$SIDECAR_NAME\")].volumeMounts[?(@.mountPath==\"$EXPECTED_MOUNT_PATH\")].name}" 2>/dev/null)

if [ -n "$sidecar_vol_name" ]; then
    log "PASS" "Sidecar container has a volume mounted at '$EXPECTED_MOUNT_PATH' (Volume Name: '$sidecar_vol_name')"
    ((PASS_COUNT++))
    
    # 6. Verify this identical volume is mounted in the nginx container to prove it is shared
    nginx_vol_mount=$(kubectl get deploy "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath="{.spec.template.spec.containers[?(@.name==\"nginx\")].volumeMounts[?(@.name==\"$sidecar_vol_name\")].mountPath}" 2>/dev/null)
    
    if [ -n "$nginx_vol_mount" ]; then
        log "PASS" "Volume '$sidecar_vol_name' is correctly shared with the 'nginx' container"
        ((PASS_COUNT++))
    else
        log "FAIL" "Volume '$sidecar_vol_name' is NOT shared/mounted inside the 'nginx' container"
        ((FAIL_COUNT++))
    fi
else
    log "FAIL" "Sidecar container does NOT have a volume mounted at '$EXPECTED_MOUNT_PATH'"
    ((FAIL_COUNT++))
fi

# ==========================================
# RESULTS SUMMARY
# ==========================================

print_summary_and_exit