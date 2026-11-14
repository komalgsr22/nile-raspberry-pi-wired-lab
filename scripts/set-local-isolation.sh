#!/usr/bin/env bash
set -euo pipefail
[[ ${EUID} -eq 0 ]] || { echo "Run with sudo"; exit 1; }
mode="${1:-}"
[[ "$mode" == "on" || "$mode" == "off" ]] || { echo "Usage: sudo bash $0 on|off"; exit 2; }
for name in victor sam amy suzy; do
  bridge link set dev "veth-$name" isolated "$mode"
done
echo "Linux bridge client port isolation: $mode"
bridge -d link show
