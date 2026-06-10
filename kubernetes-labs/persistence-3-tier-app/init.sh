#!/bin/bash

INIT_DIR="/tmp/init"

echo "==> Creating ConfigMap from init.sql..."
kubectl create configmap db-init-sql --from-file="$INIT_DIR/init.sql"

echo "==> Creating PV and PVC for database data..."
kubectl apply -f "$INIT_DIR/db-pv.yaml"
kubectl apply -f "$INIT_DIR/db-pvc.yaml"

echo "==> Deploying data injector (postgres + init.sql)..."
kubectl apply -f "$INIT_DIR/data-injector.yaml"

echo "==> Waiting for data injector to be ready..."
kubectl wait --for=condition=ready pod -l app=data-injector --timeout=120s

echo "==> Waiting for PostgreSQL to initialize data..."
sleep 10

echo "==> Verifying data was loaded..."
kubectl exec deploy/data-injector -- psql -U appuser -d appdb -c "SELECT COUNT(*) FROM products;" 2>/dev/null || true

echo "==> Removing data injector deployment (PV retained)..."
kubectl delete deployment data-injector --wait=true
kubectl delete pvc db-data-pvc

echo "==> Deploying application resources..."
kubectl apply -f "$INIT_DIR/backend.yaml"
kubectl apply -f "$INIT_DIR/frontend.yaml"
kubectl apply -f "$INIT_DIR/db.yaml"
kubectl apply -f "$INIT_DIR/backend-svc.yaml"
kubectl apply -f "$INIT_DIR/frontend-svc.yaml"
kubectl apply -f "$INIT_DIR/db-svc.yaml"

echo "==> Cleanup init directory..."
rm -rf "$INIT_DIR"

echo "==> Lab environment ready."
