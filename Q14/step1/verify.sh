#!/bin/bash

SC_NAME="custom-storage"
EXPECTED_PROVISIONER="rancher.io/local-path"
EXPECTED_MODE="WaitForFirstConsumer"
EXPECTED_DEFAULT="true"

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
    return 1
  fi

  if [ -n "$expected" ]; then
    if [ "$output" != "$expected" ]; then
      return 1
    fi
  fi

  return 0
}

echo "Validating StorageClass configuration..."

# Check existence
if check_k8s_resource sc "$SC_NAME"; then
  echo "StorageClass $SC_NAME exists"
else
  echo "StorageClass $SC_NAME does not exist"
  exit 1
fi

# Check provisioner
if check_k8s_resource sc "$SC_NAME" "" "" '{.provisioner}' "$EXPECTED_PROVISIONER"; then
  echo "Provisioner OK"
else
  echo "Provisioner NOT OK"
  exit 1
fi

# Check volumeBindingMode
if check_k8s_resource sc "$SC_NAME" "" "" '{.volumeBindingMode}' "$EXPECTED_MODE"; then
  echo "VolumeBindingMode OK"
else
  echo "VolumeBindingMode NOT OK"
  exit 1
fi

# Check default annotation
if check_k8s_resource sc "$SC_NAME" "" "" '{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}' "$EXPECTED_DEFAULT"; then
  echo "Default annotation OK"
else
  echo "Default annotation NOT OK"
  exit 1
fi

# Check no other default StorageClasses
other_defaults=$(kubectl get sc -o jsonpath='{range .items[*]}{.metadata.name}{"="}{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}' | grep "=true" | grep -v "^$SC_NAME=" || true)

if [ -n "$other_defaults" ]; then
  echo "Another StorageClass is also marked as default:"
  echo "$other_defaults"
  exit 1
else
  echo "No other default StorageClasses found"
fi

echo "All validations passed"
exit 0