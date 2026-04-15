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
  local operator="${7:-=}"

  local actual_yaml="/tmp/actual_${kind}_${name}.yaml"
  local expected_yaml="/tmp/expected_${kind}_${name}.yaml"

  # Format expected string for readability if it's a range
  local display_expected="$expected"
  if [ "$operator" = "range" ]; then
      display_expected="between ${expected/:/ and } (current: $actual)"
  fi

  # 1. Fetch the full current YAML manifest (ACTUAL)
  local get_cmd=("kubectl" "get" "$kind" "$name" "-o" "yaml")
  [ -n "$namespace" ] && get_cmd+=("-n" "$namespace")
  
  if ! "${get_cmd[@]}" > "$actual_yaml" 2>/dev/null; then
    {
      echo "--- EXPECTED (Desired State)"
      echo "+++ ACTUAL (Current State)"
      echo "- $display_expected"
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

  local safe_path="${clean_path//\\\./__DOT__}"
  IFS='.' read -ra parts <<< "$safe_path"

  local patch_json=""
  
  if [ "$operator" = "range" ]; then
    patch_json="\"$display_expected\""
  elif [[ "$expected" =~ ^[0-9]+$ ]]; then
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

  # 3. Ask Kubernetes to generate the EXPECTED YAML by patching
  local patch_cmd=("kubectl" "patch" "$kind" "$name" "--type=merge" "-p" "$patch_json" "--dry-run=client" "-o" "yaml")
  [ -n "$namespace" ] && patch_cmd+=("-n" "$namespace")

  if ! "${patch_cmd[@]}" > "$expected_yaml" 2>/dev/null; then
    # Fallback if complex patches fail (or if strict Kubernetes API rejects the range string patch)
    {
      echo "--- EXPECTED (Desired State)"
      echo "+++ ACTUAL (Current State)"
      echo "@@ Context for: $jsonpath @@"
      echo "- $display_expected"
      echo "+ $actual"
      echo ""
    } | tee -a "$OUTPUT_FILE"
    rm -f "$actual_yaml" "$expected_yaml"
    return
  fi

  # 4. Generate a clean Unified Diff
  {
    echo "--- EXPECTED (Desired State)"
    echo "+++ ACTUAL (Current State)"
  } | tee -a "$OUTPUT_FILE"

  local diff_output
  diff_output=$(diff -U 3 "$expected_yaml" "$actual_yaml" | tail -n +4)

  if [ -n "$diff_output" ]; then
    echo "$diff_output" | tee -a "$OUTPUT_FILE"
  else
    {
      echo "  (Context generation failed - raw values below)"
      echo "- $display_expected"
      echo "+ $actual"
    } | tee -a "$OUTPUT_FILE"
  fi
  
  echo "" | tee -a "$OUTPUT_FILE"
  rm -f "$actual_yaml" "$expected_yaml"
}

# --- Core check function ---
# Usage: check_k8s_resource <kind> <name> <namespace> <selector> <jsonpath> <expected> [operator]
check_k8s_resource() {
  local kind="$1"
  local name="$2"
  local namespace="$3"
  local selector="$4"
  local jsonpath="$5"
  local expected="$6"
  local operator="${7:-=}" # default to exact match

  local cmd=("kubectl" "get" "$kind")
  [ -n "$name" ] && cmd+=("$name")
  [ -n "$namespace" ] && cmd+=("-n" "$namespace")
  [ -n "$selector" ] && cmd+=("-l" "$selector")
  [ -n "$jsonpath" ] && cmd+=("-o" "jsonpath=$jsonpath")

  local output
  if ! output=$("${cmd[@]}" 2>/dev/null); then
    log "FAIL" "$kind/$name not found"
    ((FAIL_COUNT++))
    return 1
  fi

  if [ -z "$jsonpath" ]; then
    log "PASS" "$kind/$name exists"
    ((PASS_COUNT++))
    return 0
  fi

  if [ -n "$expected" ]; then
    local passed=false

    # Evaluate based on operator
    if [ "$operator" = "=" ]; then
      [ "$output" == "$expected" ] && passed=true
    elif [ "$operator" = "range" ]; then
      # Strip non-numeric characters from actual (e.g. "150m" -> "150")
      local actual_val="${output//[!0-9]/}"
      # Parse expected min and max (e.g. "100:200")
      IFS=':' read -r min max <<< "$expected"
      
      if [[ -n "$actual_val" ]] && [ "$actual_val" -ge "$min" ] 2>/dev/null && [ "$actual_val" -le "$max" ] 2>/dev/null; then
        passed=true
      fi
    fi

    if [ "$passed" = false ]; then
      log "FAIL" "$kind/$name failed check: $jsonpath"
      log_diff "$kind" "$name" "$namespace" "$jsonpath" "$expected" "$output" "$operator"
      ((FAIL_COUNT++))
      return 1
    else
      log "PASS" "$kind/$name passed: $jsonpath $operator $expected"
      ((PASS_COUNT++))
    fi
  else
    log "INFO" "$kind/$name $jsonpath = $output"
    ((INFO_COUNT++))
  fi

  return 0
}
# --- New Utilities ---
check_k8s_resource_absent() {
  local kind="$1"
  local name="$2"
  local namespace="$3"
  
  local cmd=("kubectl" "get" "$kind" "$name" "--ignore-not-found")
  [ -n "$namespace" ] && cmd+=("-n" "$namespace")

  if [ -z "$("${cmd[@]}" 2>/dev/null)" ]; then
    log "PASS" "$kind/$name is correctly absent/rejected."
    ((PASS_COUNT++))
    return 0
  else
    log "FAIL" "$kind/$name exists but should not."
    ((FAIL_COUNT++))
    return 1
  fi
}

check_k8s_resource_contains() {
  local kind="$1"
  local name="$2"
  local namespace="$3"
  local jsonpath="$4"
  local expected_substring="$5"

  local cmd=("kubectl" "get" "$kind" "$name" "-o" "jsonpath=$jsonpath")
  [ -n "$namespace" ] && cmd+=("-n" "$namespace")

  local output=$("${cmd[@]}" 2>/dev/null)
  
  if [[ "$output" == *"$expected_substring"* ]]; then
    log "PASS" "$kind/$name [$jsonpath] contains '$expected_substring'"
    ((PASS_COUNT++))
    return 0
  else
    log "FAIL" "$kind/$name [$jsonpath] does NOT contain '$expected_substring'. Found: '$output'"
    ((FAIL_COUNT++))
    return 1
  fi
}

check_http_status() {
  local url="$1"
  local expected_code="$2"
  local max_retries="${3:-5}"
  local sleep_time="${4:-2}"
  local extra_curl_args="${5:-}"

  log "INFO" "Testing reachability of $url (Expected HTTP $expected_code)..."
  
  local http_code="000"
  for ((i=1; i<=max_retries; i++)); do
    http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 $extra_curl_args "$url" || echo "000")
    if [ "$http_code" == "$expected_code" ]; then
      log "PASS" "Successfully received HTTP $expected_code from $url"
      ((PASS_COUNT++))
      return 0
    fi
    sleep "$sleep_time"
  done

  log "FAIL" "Failed to reach $url. Expected HTTP $expected_code, got $http_code."
  ((FAIL_COUNT++))
  return 1
}

check_pod_curl() {
  local from_pod="$1"
  local from_ns="$2"
  local target_url="$3"
  local expected_code="$4"
  local timeout="${5:-3}"

  local http_code=$(kubectl exec -n "$from_ns" "$from_pod" -- curl -s -o /dev/null -w "%{http_code}" --max-time "$timeout" "$target_url" 2>/dev/null || echo "000")

  if [ "$http_code" == "$expected_code" ]; then
    log "PASS" "Pod $from_pod successfully received HTTP $expected_code from $target_url"
    ((PASS_COUNT++))
    return 0
  else
    log "FAIL" "Pod $from_pod expected HTTP $expected_code from $target_url, got $http_code"
    ((FAIL_COUNT++))
    return 1
  fi
}

check_local_file() {
  local filepath="$1"
  local expected_content="$2" # Optional

  if [ ! -f "$filepath" ]; then
    log "FAIL" "File $filepath does not exist."
    ((FAIL_COUNT++))
    return 1
  fi

  if [ -z "$expected_content" ]; then
    log "PASS" "File $filepath exists."
    ((PASS_COUNT++))
    return 0
  fi

  if grep -qE "$expected_content" "$filepath"; then
    log "PASS" "File $filepath contains expected content ('$expected_content')."
    ((PASS_COUNT++))
    return 0
  else
    log "FAIL" "File $filepath exists but is missing expected content ('$expected_content')."
    ((FAIL_COUNT++))
    return 1
  fi
}

wait_and_check_rollout() {
  local kind="$1"
  local name="$2"
  local namespace="$3"
  local timeout="${4:-15s}"

  log "INFO" "Waiting up to $timeout for $kind/$name rollout..."
  if kubectl rollout status "$kind" "$name" -n "$namespace" --timeout="$timeout" >/dev/null 2>&1; then
    log "PASS" "$kind/$name has successfully rolled out and is Ready."
    ((PASS_COUNT++))
    return 0
  else
    log "FAIL" "$kind/$name failed to rollout or timed out."
    ((FAIL_COUNT++))
    # Automatically print the reason for the failure (Pending pods, CrashLoop, etc.)
    kubectl get pods -n "$namespace" -l "app=$name" --field-selector status.phase!=Running | tee -a "$OUTPUT_FILE"
    return 1
  fi
}
# Checks if a systemd service is active and enabled
# Solves: Q9 (cri-dockerd systemd check)
check_systemd_service() {
  local svc_name="$1"
  
  if systemctl is-enabled --quiet "$svc_name" 2>/dev/null && systemctl is-active --quiet "$svc_name" 2>/dev/null; then
    log "PASS" "Service $svc_name is active and enabled."
    ((PASS_COUNT++))
  else
    log "FAIL" "Service $svc_name is either NOT active or NOT enabled."
    ((FAIL_COUNT++))
  fi
}

# Checks if a debian package is installed
# Solves: Q9 (cri-dockerd apt check)
check_deb_package() {
  local pkg_name="$1"
  
  if dpkg-query -W -f='${Status}' "$pkg_name" 2>/dev/null | grep -q "install ok installed"; then
    log "PASS" "Debian package $pkg_name is installed."
    ((PASS_COUNT++))
  else
    log "FAIL" "Debian package $pkg_name is NOT installed."
    ((FAIL_COUNT++))
  fi
}

check_sysctl_active() {
  local param="$1"
  local expected="$2"
  
  local actual=$(sysctl -n "$param" 2>/dev/null)
  if [ "$actual" == "$expected" ]; then
    log "PASS" "sysctl $param is actively applied ($actual)"
    ((PASS_COUNT++))
  else
    log "FAIL" "sysctl $param is NOT actively applied (expected: $expected, actual: $actual)"
    ((FAIL_COUNT++))
  fi
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