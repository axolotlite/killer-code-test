#!/bin/bash

NS="postgres"
PVC="postgres"
DEPLOYMENT="postgres"
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

if check_k8s_resource namespace postgres; then
  echo "Namespace exists"
else
  echo "Namespace missing"
fi

kubectl get deploy -n $NS $DEPLO

if check_k8s_resource pv postgres postgres "" '{.spec.accessModes[0]}' $PV_ACCESS; then
  echo "Access mode OK"
else
  echo "Access mode NOT OK"
fi

if check_k8s_resource pv postgres postgres "" '{.spec.resources.requests.storage}' $PV_SIZE; then
  echo "PV Size OK"
else
  echo "PV Size NOT OK"
fi
