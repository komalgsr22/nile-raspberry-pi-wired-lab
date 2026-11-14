#!/usr/bin/env bash
set -euo pipefail
echo "== Namespaces =="
ip netns list
echo "== Client virtual interfaces =="
for name in victor sam amy suzy; do
  echo "=== $name ==="
  ip netns exec "$name" ip -br addr show eth0
done
echo "== Bridge member ports =="
bridge -d link show
echo "== Main host physical interface summary =="
ip -br link show eth0
ip -br link show wlan0
