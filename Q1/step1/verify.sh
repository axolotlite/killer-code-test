#!/bin/bash

NS="postgres"
PVC="postgres"
DEPLOYMENT="postgres"
PV_NAME="postgres-pv"
PV_SIZE="250Mi"
PV_ACCESS="ReadWriteOnce"

check_k8s_resource() {
  # Arguments
  local kind="$1"
  local name="$2"
  local namespace="$3"
  local selector="$4"
  local jsonpath="$5"
  local expected="$6"

  # Build kubectl command
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

if check_k8s_resource namespace $NS; then
  echo "Namespace $NS exists"
else
  echo "Namespace $NS is missing"
fi

if check_k8s_resource deployment $DEPLOYMENT $NS; then
  echo "Deployment $DEPLOYMENT exists in $NS"
else
  echo "Deployment $DEPLOYMENT doesn't exist in $NS"
  exit 1
fi

if check_k8s_resource pv postgres-pv postgres "" '{.spec.accessModes[0]}' $PV_ACCESS; then
  echo "Access mode OK"
else
  echo "Access mode NOT OK"
  exit 1
fi

if check_k8s_resource pv postgres-pv postgres "" '{.spec.capacity.storage}' $PV_SIZE; then
  echo "PV Size OK"
else
  echo "PV Size NOT OK"
  exit 1
fi

if check_k8s_resource pvc postgres postgres "" '{.spec.resources.requests.storage}' $PV_SIZE; then
  echo "PVC Size OK"
else
  echo "PVC Size NOT OK"
  exit 1
fi

if check_k8s_resource pvc postgres postgres "" '{.spec.volumeName}' $PV_NAME; then
  echo "PVC is using correct PV"
else
  echo "PVC is using the incorrect PV"
  exit 1
fi
