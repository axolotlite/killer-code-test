#!/bin/bash

INIT_DIR="/tmp/init"

echo "First initiating any namespaces"
kubectl apply -f "$INIT_DIR/namespace.yaml"

echo "Setting up the rest of the resources"
kubectl apply -f "$INIT_DIR/*.yaml"

rm -rf $INIT_DIR