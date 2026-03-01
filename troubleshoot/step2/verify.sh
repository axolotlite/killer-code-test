#!/bin/bash
POD="kube-controller-manager-$(hostname)"
NS="kube-system"

PHASE=$(kubectl -n $NS get pod $POD \
  -o jsonpath='{.status.phase}')

if [ "$PHASE" != "Running" ]; then
  exit 1
fi

CPU_REQUEST=$(kubectl -n $NS get pod $POD -o yaml | yq '.spec.containers[0].resources.requests.cpu')

# Convert "m" to integer
CPU_VALUE=${CPU_REQUEST%m}  # e.g., "150m" -> 150

# Check thresholds
if [ "$CPU_VALUE" -ge 100 ] && [ "$CPU_VALUE" -le 200 ]; then
    exit 0
else
    exit 1    
fi