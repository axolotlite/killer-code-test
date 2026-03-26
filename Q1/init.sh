#!/bin/bash

INIT_DIR="/tmp/init"

kubectl apply -f $INIT_DIR

rm -rf $INIT_DIR