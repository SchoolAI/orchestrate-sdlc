#!/bin/bash
# Pre-tool-use hook: block test commands when available RAM is below threshold.
# Works on macOS (vm_stat) and Linux (/proc/meminfo).

set -euo pipefail

THRESHOLD_GB=10
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Nothing to check if there's no command
[ -z "$COMMAND" ] && exit 0

# Only gate test-related commands
if ! echo "$COMMAND" | grep -qEi '(npm\s+test|npx\s+(vitest|jest)|vitest|jest)\b'; then
  exit 0
fi

# Calculate available memory (platform-specific)
if [[ "$(uname)" == "Darwin" ]]; then
  page_size=$(sysctl -n hw.pagesize)
  read -r free_pages inactive_pages < <(
    vm_stat | awk '
      /Pages free/     { gsub(/\./,"",$3); free=$3 }
      /Pages inactive/ { gsub(/\./,"",$3); inactive=$3 }
      END { print free, inactive }
    '
  )
  available_bytes=$(( (free_pages + inactive_pages) * page_size ))
else
  # Linux: MemAvailable from /proc/meminfo (kB)
  available_kb=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
  available_bytes=$(( available_kb * 1024 ))
fi

available_gb=$(( available_bytes / 1073741824 ))

if [ "$available_gb" -lt "$THRESHOLD_GB" ]; then
  echo "Memory guardrail: only ${available_gb}GB available (threshold: ${THRESHOLD_GB}GB). Wait for other test runs to finish before starting another." >&2
  exit 2
fi

exit 0
