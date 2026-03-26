#!/bin/bash

kubectl wait --for=condition=Available deployment/postgres -n postgres --timeout=10s || true

kubectl delete deployment postgres -n postgres --ignore-not-found
kubectl delete pvc postgres -n postgres --ignore-not-found