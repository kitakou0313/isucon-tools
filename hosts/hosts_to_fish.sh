#!/bin/bash
# Bridges hosts/hosts.txt (bash-only syntax with arrays) into fish shell.
# Usage from fish: bash ./hosts/hosts_to_fish.sh | source
set -e

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$dir/hosts.txt"

var_names=$(grep -oE '^[A-Za-z_][A-Za-z0-9_]*=' "$dir/hosts.txt" | sed 's/=$//' | sort -u)

for var in $var_names; do
  if [[ "$(declare -p "$var" 2>/dev/null)" == "declare -a"* ]]; then
    eval "vals=(\"\${$var[@]}\")"
    printf 'set -gx %s' "$var"
    for v in "${vals[@]}"; do printf ' %s' "$v"; done
    printf '\n'
  else
    printf 'set -gx %s %s\n' "$var" "${!var}"
  fi
done
