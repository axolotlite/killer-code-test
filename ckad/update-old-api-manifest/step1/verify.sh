#!/bin/bash
# verify.sh - Step 1: Workload & Policy API Version Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

log "INFO" "Running Step 1 — Workload API Version Validations..."
echo "" | tee -a "$OUTPUT_FILE"

NS="garland"

# Task 1: Deployment web exists and uses apps/v1
check_k8s_resource deployment "web" "$NS" "" "" ""

# Verify apiVersion via raw manifest check
DEP_API=$(kubectl get deployment web -n "$NS" -o jsonpath='{.apiVersion}' 2>/dev/null)
if [ "$DEP_API" == "apps/v1" ]; then
  log "PASS" "Deployment web uses apiVersion apps/v1"
  ((PASS_COUNT++))
else
  log "FAIL" "Deployment web apiVersion is '$DEP_API', expected 'apps/v1'"
  ((FAIL_COUNT++))
fi

# Verify selector.matchLabels exists and matches template labels
check_k8s_resource deployment "web" "$NS" "" '{.spec.selector.matchLabels.app}' "web"
check_k8s_resource deployment "web" "$NS" "" '{.spec.template.metadata.labels.app}' "web"

# Verify replicas
check_k8s_resource deployment "web" "$NS" "" '{.spec.replicas}' "2"

# Deployment rollout
wait_and_check_rollout deployment "web" "$NS" "30s"

# Task 2: DaemonSet log-collector exists and uses apps/v1
check_k8s_resource daemonset "log-collector" "$NS" "" "" ""

DS_API=$(kubectl get daemonset log-collector -n "$NS" -o jsonpath='{.apiVersion}' 2>/dev/null)
if [ "$DS_API" == "apps/v1" ]; then
  log "PASS" "DaemonSet log-collector uses apiVersion apps/v1"
  ((PASS_COUNT++))
else
  log "FAIL" "DaemonSet log-collector apiVersion is '$DS_API', expected 'apps/v1'"
  ((FAIL_COUNT++))
fi

# Verify selector.matchLabels
check_k8s_resource daemonset "log-collector" "$NS" "" '{.spec.selector.matchLabels.app}' "log-collector"
check_k8s_resource daemonset "log-collector" "$NS" "" '{.spec.template.metadata.labels.app}' "log-collector"

# Task 3: CronJob cleanup exists and uses batch/v1
check_k8s_resource cronjob "cleanup" "$NS" "" "" ""

CJ_API=$(kubectl get cronjob cleanup -n "$NS" -o jsonpath='{.apiVersion}' 2>/dev/null)
if [ "$CJ_API" == "batch/v1" ]; then
  log "PASS" "CronJob cleanup uses apiVersion batch/v1"
  ((PASS_COUNT++))
else
  log "FAIL" "CronJob cleanup apiVersion is '$CJ_API', expected 'batch/v1'"
  ((FAIL_COUNT++))
fi

# Task 4: PodDisruptionBudget web-pdb exists and uses policy/v1
check_k8s_resource pdb "web-pdb" "$NS" "" "" ""

PDB_API=$(kubectl get pdb web-pdb -n "$NS" -o jsonpath='{.apiVersion}' 2>/dev/null)
if [ "$PDB_API" == "policy/v1" ]; then
  log "PASS" "PodDisruptionBudget web-pdb uses apiVersion policy/v1"
  ((PASS_COUNT++))
else
  log "FAIL" "PodDisruptionBudget web-pdb apiVersion is '$PDB_API', expected 'policy/v1'"
  ((FAIL_COUNT++))
fi

check_k8s_resource pdb "web-pdb" "$NS" "" '{.spec.minAvailable}' "1"

print_summary_and_exit
