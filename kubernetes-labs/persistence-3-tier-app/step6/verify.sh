#!/bin/bash
# verify.sh - Step 6: Frontend Shows Data
OUTPUT_FILE="${OUTPUT_FILE:-$HOME/validation.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utility.sh"

log "INFO" "Validating Step 6: Frontend Shows Data..."
echo "" | tee -a "$OUTPUT_FILE"

# Check frontend is reachable and contains product data
RESPONSE=$(curl -s --max-time 5 http://localhost:31080 2>/dev/null || echo "")

if echo "$RESPONSE" | grep -q "Wireless Keyboard"; then
  log "PASS" "Frontend displays product data from database"
  ((PASS_COUNT++))
else
  log "FAIL" "Frontend does not display product data - database may not be connected to PVC"
  ((FAIL_COUNT++))
fi

if echo "$RESPONSE" | grep -q "Database Empty"; then
  log "FAIL" "Frontend still shows 'Database Empty' warning"
  ((FAIL_COUNT++))
else
  log "PASS" "Frontend no longer shows empty database warning"
  ((PASS_COUNT++))
fi

print_summary_and_exit
