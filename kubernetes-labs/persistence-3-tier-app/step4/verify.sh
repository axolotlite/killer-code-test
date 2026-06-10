#!/bin/bash
# verify.sh - Step 4: Frontend Accessible
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

log "INFO" "Validating Step 4: Frontend Accessible..."
echo "" | tee -a "$OUTPUT_FILE"

check_http_status "http://localhost:31080" "200" 5 3

print_summary_and_exit
