#!/bin/bash

SC_NAME="local-storage"
EXPECTED_PROVISIONER="rancher.io/local-path"
EXPECTED_MODE="WaitForFirstConsumer"
EXPECTED_DEFAULT="true"

OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

# --- Logging ---
log() {
  local level="$1"
  local message="$2"
  echo "[$level] $message" | tee -a "$OUTPUT_FILE"
}

log_diff() {
  local resource="$1"
  local field="$2"
  local expected="$3"
  local actual="$4"

  {
    echo "--- EXPECTED"
    echo "+++ ACTUAL"
    echo "@@ $resource :: $field @@"
    echo "- $expected"
    echo "+ $actual"
  } | tee -a "$OUTPUT_FILE"
}

# --- Core check function ---
check_k8s_resource() {
  local kind="$1"
  local name="$2"
  local namespace="$3"
  local selector="$4"
  local jsonpath="$5"
  local expected="$6"

  local cmd=("kubectl" "get" "$kind")
  [ -n "$name" ] && cmd+=("$name")
  [ -n "$namespace" ] && cmd+=("-n" "$namespace")
  [ -n "$selector" ] && cmd+=("-l" "$selector")

  if [ -n "$jsonpath" ]; then
    cmd+=("-o" "jsonpath=$jsonpath")
  fi

  local output
  if ! output=$("${cmd[@]}" 2>/dev/null); then
    log "ERROR" "$kind/$name not found"
    return 1
  fi

  if [ -z "$jsonpath" ]; then
    log "INFO" "$kind/$name exists"
    return 0
  fi

  if [ -n "$expected" ]; then
    if [ "$output" != "$expected" ]; then
      log "ERROR" "$kind/$name failed check: $jsonpath"
      log_diff "$kind/$name" "$jsonpath" "$expected" "$output"
      return 1
    else
      log "OK" "$kind/$name passed: $jsonpath = $output"
    fi
  else
    log "INFO" "$kind/$name $jsonpath = $output"
  fi

  return 0
}

log "INFO" "Validating StorageClass configuration..."

# Existence
check_k8s_resource sc "$SC_NAME" "" "" "" "" || exit 1

# Provisioner
check_k8s_resource sc "$SC_NAME" "" "" '{.provisioner}' "$EXPECTED_PROVISIONER" || exit 1

# VolumeBindingMode
check_k8s_resource sc "$SC_NAME" "" "" '{.volumeBindingMode}' "$EXPECTED_MODE" || exit 1

# Default annotation
check_k8s_resource sc "$SC_NAME" "" "" '{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}' "$EXPECTED_DEFAULT" || exit 1

# Check for other defaults (enhanced logging)
other_defaults=$(kubectl get sc -o jsonpath='{range .items[*]}{.metadata.name}{"="}{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}' | grep "=true" | grep -v "^$SC_NAME=" || true)

if [ -n "$other_defaults" ]; then
  log "ERROR" "Multiple default StorageClasses detected"
  echo "$other_defaults" | tee -a "$OUTPUT_FILE"
  exit 1
else
  log "OK" "No other default StorageClasses found"
fi

log "SUCCESS" "All validations passed"
exit 0