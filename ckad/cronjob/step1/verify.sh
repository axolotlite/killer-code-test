#!/bin/bash
# verify.sh - CronJob Scheduling & Configuration Validation
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

log "INFO" "Running CronJob Validations..."
echo "" | tee -a "$OUTPUT_FILE"

# Task 1: CronJob exists
check_k8s_resource cronjob "nameserver" "" "" "" ""

# Task 1a: Container name
check_k8s_resource cronjob "nameserver" "" "" '{.spec.jobTemplate.spec.template.spec.containers[0].name}' "busybox"

# Task 1b: Image
check_k8s_resource cronjob "nameserver" "" "" '{.spec.jobTemplate.spec.template.spec.containers[0].image}' "busybox:stable"

# Task 1c: Command
check_k8s_resource_contains cronjob "nameserver" "" '{.spec.jobTemplate.spec.template.spec.containers[0].command}' "grep"
check_k8s_resource_contains cronjob "nameserver" "" '{.spec.jobTemplate.spec.template.spec.containers[0].command}' "nameserver"
check_k8s_resource_contains cronjob "nameserver" "" '{.spec.jobTemplate.spec.template.spec.containers[0].command}' "/etc/resolv.conf"

# Task 2a: Schedule - every 30 minutes
check_k8s_resource cronjob "nameserver" "" "" '{.spec.schedule}' "*/30 * * * *"

# Task 2b: Successful Jobs History Limit
check_k8s_resource cronjob "nameserver" "" "" '{.spec.successfulJobsHistoryLimit}' "50"

# Task 2c: Failed Jobs History Limit
check_k8s_resource cronjob "nameserver" "" "" '{.spec.failedJobsHistoryLimit}' "100"

# Task 3a: Restart Policy
check_k8s_resource cronjob "nameserver" "" "" '{.spec.jobTemplate.spec.template.spec.restartPolicy}' "Never"

# Task 3b: Active Deadline Seconds
check_k8s_resource cronjob "nameserver" "" "" '{.spec.jobTemplate.spec.template.spec.activeDeadlineSeconds}' "8"

# Task 4: Manual Job created from CronJob
check_k8s_resource job "nameserver-resolver" "" "" "" ""

# Verify the manual job was created from the correct cronjob
if kubectl get job nameserver-resolver -o jsonpath='{.metadata.annotations}' 2>/dev/null | grep -q "nameserver"; then
  log "PASS" "Job nameserver-resolver was created from the nameserver CronJob."
  ((PASS_COUNT++))
else
  log "FAIL" "Job nameserver-resolver does not appear to be created from the nameserver CronJob."
  ((FAIL_COUNT++))
fi

print_summary_and_exit