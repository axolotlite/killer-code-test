#!/bin/bash
# utility.sh - Reusable Kubernetes Validation Library

OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

# Global Counters
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0
INFO_COUNT=0

# Init log file safely
> "$OUTPUT_FILE"

# --- Logging ---
log() {
  local level="$1"
  local message="$2"
  # Log to console and file simultaneously
  echo "[$level] $message" | tee -a "$OUTPUT_FILE"
}

log_diff() {
  local kind="$1"
  local name="$2"
  local namespace="$3"
  local jsonpath="$4"
  local expected="$5"
  local actual="$6"

  local actual_yaml="/tmp/actual_${kind}_${name}.yaml"
  local expected_yaml="/tmp/expected_${kind}_${name}.yaml"

  # 1. Fetch the full current YAML manifest (ACTUAL)
  local get_cmd=("kubectl" "get" "$kind" "$name" "-o" "yaml")
  [ -n "$namespace" ] && get_cmd+=("-n" "$namespace")
  
  if ! "${get_cmd[@]}" > "$actual_yaml" 2>/dev/null; then
    {
      echo "--- EXPECTED (Desired State)"
      echo "+++ ACTUAL (Current State)"
      echo "- $expected"
      echo "+ $actual"
      echo ""
    } | tee -a "$OUTPUT_FILE"
    return
  fi

  # 2. Convert the JSONPath into a Strategic Merge JSON Patch
  local clean_path="${jsonpath}"
  clean_path="${clean_path#\{}"
  clean_path="${clean_path%\}}"
  clean_path="${clean_path#\.}"

  # Protect escaped dots (e.g. storageclass\.kubernetes\.io) during split
  local safe_path="${clean_path//\\\./__DOT__}"
  IFS='.' read -ra parts <<< "$safe_path"

  local patch_json=""
  
  # Heuristic for JSON data types (Annotations/Labels require strings)
  if [[ "$expected" =~ ^[0-9]+$ ]]; then
    patch_json="$expected"
  elif [[ "$expected" == "true" || "$expected" == "false" ]]; then
    if [[ "$safe_path" == *"annotations"* || "$safe_path" == *"labels"* ]]; then
      patch_json="\"$expected\""
    else
      patch_json="$expected"
    fi
  else
    patch_json="\"$expected\""
  fi

  # Build the nested JSON backwards
  for (( i=${#parts[@]}-1; i>=0; i-- )); do
    local key="${parts[i]//__DOT__/.}"
    patch_json="{\"${key}\": ${patch_json}}"
  done

  # 3. Ask Kubernetes to generate the EXPECTED YAML by patching the live manifest in memory
  local patch_cmd=("kubectl" "patch" "$kind" "$name" "--type=merge" "-p" "$patch_json" "--dry-run=client" "-o" "yaml")
  [ -n "$namespace" ] && patch_cmd+=("-n" "$namespace")

  if ! "${patch_cmd[@]}" > "$expected_yaml" 2>/dev/null; then
    # Fallback if complex patches (like arrays) fail
    {
      echo "--- EXPECTED (Desired State)"
      echo "+++ ACTUAL (Current State)"
      echo "@@ Context for: $jsonpath @@"
      echo "- $expected"
      echo "+ $actual"
      echo ""
    } | tee -a "$OUTPUT_FILE"
    rm -f "$actual_yaml" "$expected_yaml"
    return
  fi

  # 4. Generate a clean Unified Diff directly to console and log
  {
    echo "--- EXPECTED (Desired State)"
    echo "+++ ACTUAL (Current State)"
  } | tee -a "$OUTPUT_FILE"

  # `diff -U 3` creates standard diff context. `tail -n +4` removes file metadata headers.
  local diff_output
  diff_output=$(diff -U 3 "$expected_yaml" "$actual_yaml" | tail -n +4)

  if [ -n "$diff_output" ]; then
    echo "$diff_output" | tee -a "$OUTPUT_FILE"
  else
    {
      echo "  (Context generation failed - raw values below)"
      echo "- $expected"
      echo "+ $actual"
    } | tee -a "$OUTPUT_FILE"
  fi
  
  echo "" | tee -a "$OUTPUT_FILE"

  # Cleanup
  rm -f "$actual_yaml" "$expected_yaml"
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
    log "FAIL" "$kind/$name not found"
    ((FAIL_COUNT++))
    return 1
  fi

  # Check existence only
  if [ -z "$jsonpath" ]; then
    log "PASS" "$kind/$name exists"
    ((PASS_COUNT++))
    return 0
  fi

  # Value validation check
  if [ -n "$expected" ]; then
    if [ "$output" != "$expected" ]; then
      log "FAIL" "$kind/$name failed check: $jsonpath"
      log_diff "$kind" "$name" "$namespace" "$jsonpath" "$expected" "$output"
      ((FAIL_COUNT++))
      return 1
    else
      log "PASS" "$kind/$name passed: $jsonpath = $output"
      ((PASS_COUNT++))
    fi
  else
    # Informational readout only
    log "INFO" "$kind/$name $jsonpath = $output"
    ((INFO_COUNT++))
  fi

  return 0
}

# --- Summary Output ---
print_summary_and_exit() {
  {
    echo ""
    echo "== Validation Summary =="
    echo "$PASS_COUNT checks PASS"
    echo "$FAIL_COUNT checks FAIL"
    echo "$WARN_COUNT checks WARN"
    echo "$INFO_COUNT checks INFO"
    echo ""
  } | tee -a "$OUTPUT_FILE"

  if [ "$FAIL_COUNT" -gt 0 ]; then
    log "FAIL" "Validations completed with errors. Please review the output above or check $OUTPUT_FILE."
    exit 1
  else
    log "PASS" "All validations passed successfully."
    exit 0
  fi
}