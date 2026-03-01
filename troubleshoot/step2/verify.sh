#!/bin/bash

NS="kube-system"
PODS=("kube-controller-manager" "kube-scheduler")

for BASE_POD in "${PODS[@]}"; do
    POD="$BASE_POD-$(hostname)"

    # Check if Pod is Running
    PHASE=$(kubectl -n $NS get pod $POD -o jsonpath='{.status.phase}')
    if [ "$PHASE" != "Running" ]; then
        echo "$POD is not Running (phase: $PHASE)"
        exit 1
    fi

    # Get CPU request
    CPU_REQUEST=$(kubectl -n $NS get pod $POD -o yaml | yq '.spec.containers[0].resources.requests.cpu')
    CPU_VALUE=${CPU_REQUEST%m}  # Convert "150m" -> 150

    # Check CPU threshold
    if [ "$CPU_VALUE" -ge 100 ] && [ "$CPU_VALUE" -le 200 ]; then
        echo "$POD CPU request within range: $CPU_REQUEST"
    else
        echo "$POD CPU request out of range: $CPU_REQUEST"
        exit 1
    fi
done

exit 0