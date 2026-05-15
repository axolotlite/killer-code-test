#!/bin/bash
# verify.sh - Step 2: Ingress API Version Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

log "INFO" "Running Step 2 — Ingress API Version Validations..."
echo "" | tee -a "$OUTPUT_FILE"

NS="garland"

# Task 1: Ingress exists
check_k8s_resource ingress "web-ingress" "$NS" "" "" ""

# Verify apiVersion
ING_API=$(kubectl get ingress web-ingress -n "$NS" -o jsonpath='{.apiVersion}' 2>/dev/null)
if [ "$ING_API" == "networking.k8s.io/v1" ]; then
  log "PASS" "Ingress web-ingress uses apiVersion networking.k8s.io/v1"
  ((PASS_COUNT++))
else
  log "FAIL" "Ingress web-ingress apiVersion is '$ING_API', expected 'networking.k8s.io/v1'"
  ((FAIL_COUNT++))
fi

# Verify host
check_k8s_resource ingress "web-ingress" "$NS" "" '{.spec.rules[0].host}' "example.local"

# Path 1: / -> web:80
check_k8s_resource ingress "web-ingress" "$NS" "" '{.spec.rules[0].http.paths[0].path}' "/"
check_k8s_resource ingress "web-ingress" "$NS" "" '{.spec.rules[0].http.paths[0].pathType}' "Prefix"
check_k8s_resource ingress "web-ingress" "$NS" "" '{.spec.rules[0].http.paths[0].backend.service.name}' "web"
check_k8s_resource ingress "web-ingress" "$NS" "" '{.spec.rules[0].http.paths[0].backend.service.port.number}' "80"

# Path 2: /api -> api:8080
check_k8s_resource ingress "web-ingress" "$NS" "" '{.spec.rules[0].http.paths[1].path}' "/api"
check_k8s_resource ingress "web-ingress" "$NS" "" '{.spec.rules[0].http.paths[1].pathType}' "Prefix"
check_k8s_resource ingress "web-ingress" "$NS" "" '{.spec.rules[0].http.paths[1].backend.service.name}' "api"
check_k8s_resource ingress "web-ingress" "$NS" "" '{.spec.rules[0].http.paths[1].backend.service.port.number}' "8080"

# Verify old-style backend fields are NOT present in the source file
INGRESS_FILE="$HOME/deploy/ingress.yaml"
if [ -f "$INGRESS_FILE" ]; then
  if grep -q "serviceName" "$INGRESS_FILE" || grep -q "servicePort" "$INGRESS_FILE"; then
    log "FAIL" "~/deploy/ingress.yaml still contains old backend format (serviceName/servicePort)"
    ((FAIL_COUNT++))
  else
    log "PASS" "~/deploy/ingress.yaml uses the new backend format (service.name/service.port.number)"
    ((PASS_COUNT++))
  fi
else
  log "FAIL" "~/deploy/ingress.yaml not found"
  ((FAIL_COUNT++))
fi

print_summary_and_exit
