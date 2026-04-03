#!/bin/bash
# Session-start hook: background watchdog that monitors for runaway test processes.
# Kills excess node/vitest/jest processes when counts exceed safe thresholds.

set -uo pipefail

POLL_INTERVAL=5          # seconds between checks
MAX_TEST_PROCESSES=15    # total test-runner processes before intervention
LOG_FILE="${TMPDIR:-/tmp}/claude-watchdog-$$.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

log "Watchdog started (pid $$, poll every ${POLL_INTERVAL}s, max test procs: ${MAX_TEST_PROCESSES})"
echo "Process watchdog started (pid $$, log: $LOG_FILE)"

cleanup() {
  log "Watchdog shutting down"
  exit 0
}
trap cleanup SIGTERM SIGINT

while true; do
  # Find node processes running test-related commands
  test_pids=()
  while IFS= read -r line; do
    pid=$(echo "$line" | awk '{print $1}')
    cmd=$(echo "$line" | awk '{$1=""; print $0}' | xargs)
    if echo "$cmd" | grep -qEi '(vitest|jest|node.*vitest|node.*jest)'; then
      test_pids+=("$pid")
    fi
  done < <(ps -eo pid,command 2>/dev/null | grep -i '[n]ode\|[v]itest\|[j]est' || true)

  count=${#test_pids[@]}

  if [ "$count" -gt "$MAX_TEST_PROCESSES" ]; then
    log "ALERT: $count test processes detected (limit: $MAX_TEST_PROCESSES)"

    # Kill the newest processes first (higher PID = newer)
    excess=$(( count - MAX_TEST_PROCESSES ))
    log "Killing $excess newest test processes to bring count under limit"

    printf '%s\n' "${test_pids[@]}" | sort -rn | head -n "$excess" | while read -r kill_pid; do
      cmd=$(ps -p "$kill_pid" -o command= 2>/dev/null || echo "unknown")
      log "Killing PID $kill_pid: $cmd"
      kill -TERM "$kill_pid" 2>/dev/null || true
    done

    # Force kill survivors after 3 seconds
    sleep 3
    printf '%s\n' "${test_pids[@]}" | sort -rn | head -n "$excess" | while read -r kill_pid; do
      if kill -0 "$kill_pid" 2>/dev/null; then
        log "Force killing PID $kill_pid"
        kill -9 "$kill_pid" 2>/dev/null || true
      fi
    done
  fi

  sleep "$POLL_INTERVAL"
done
