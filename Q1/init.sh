#!/bin/bash

INIT_DIR="/tmp/init"

kubectl apply -f "$INIT_DIR/namespace.yaml"

kubectl apply -f "$INIT_DIR/*.yaml"

# rm -rf $INIT_DIR