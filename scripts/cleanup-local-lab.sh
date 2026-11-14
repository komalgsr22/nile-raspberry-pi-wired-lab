#!/usr/bin/env bash
set -euo pipefail
[[ ${EUID} -eq 0 ]] || { echo "Run with sudo"; exit 1; }
echo "WARNING: removes named lab virtual interfaces and namespaces. Press Ctrl+C to cancel."
for name in victor sam amy suzy; do
  ip link delete "veth-$name" 2>/dev/null || true
  ip netns delete "$name" 2>/dev/null || true
done
ip link delete br-lab 2>/dev/null || true
echo "Local named lab removed. Physical eth0 and wlan0 were not modified."
