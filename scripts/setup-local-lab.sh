#!/usr/bin/env bash
set -euo pipefail
[[ ${EUID} -eq 0 ]] || { echo "Run with sudo"; exit 1; }
names=(victor sam amy suzy)
ips=(11 12 13 14)
if ! ip link show br-lab >/dev/null 2>&1; then ip link add br-lab type bridge; fi
ip link set br-lab up
for i in "${!names[@]}"; do
  name="${names[$i]}"
  suffix=$(printf '%02x' $((i+1)))
  if ! ip netns list | awk '{print $1}' | grep -Fxq "$name"; then ip netns add "$name"; fi
  if ! ip link show "veth-$name" >/dev/null 2>&1; then
    # A half-existing state is intentional failure, not something to silently overwrite.
    if ip netns exec "$name" ip link show eth0 >/dev/null 2>&1; then
      echo "Unexpected existing eth0 in namespace $name; inspect before continuing" >&2; exit 1
    fi
    ip link add "veth-$name" type veth peer name "veth-$name-ns"
    ip link set "veth-$name-ns" netns "$name"
    ip netns exec "$name" ip link set "veth-$name-ns" name eth0
  fi
  ip netns exec "$name" ip link set dev eth0 address "02:77:00:00:00:$suffix"
  ip netns exec "$name" ip addr replace "10.240.77.${ips[$i]}/24" dev eth0
  ip netns exec "$name" ip link set lo up
  ip netns exec "$name" ip link set eth0 up
  ip link set "veth-$name" master br-lab
  ip link set "veth-$name" up
done
echo "Local four-client lab ready. Physical eth0 and wlan0 were untouched."
