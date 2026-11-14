#!/usr/bin/env bash
set -euo pipefail
[[ ${EUID} -eq 0 ]] || { echo "Run with sudo"; exit 1; }
rounds=1
interval=5
while (($#)); do
  case "$1" in
    --once) rounds=1; shift;;
    --rounds) rounds="${2:-}"; shift 2;;
    --interval) interval="${2:-}"; shift 2;;
    *) echo "Usage: sudo bash $0 [--once|--rounds N] [--interval SECONDS]"; exit 2;;
  esac
done
[[ "$rounds" =~ ^[1-9][0-9]*$ ]] || { echo "rounds must be a positive integer"; exit 2; }
[[ "$interval" =~ ^[0-9]+$ ]] || { echo "interval must be a nonnegative integer"; exit 2; }
names=(victor sam amy suzy)
ips=(10.240.77.11 10.240.77.12 10.240.77.13 10.240.77.14)
for ((r=1;r<=rounds;r++)); do
  echo "=== Traffic round $r of $rounds ==="
  for i in "${!names[@]}"; do
    for j in "${!names[@]}"; do
      if ((i == j)); then continue; fi
      if ip netns exec "${names[$i]}" ping -n -c 1 -W 1 "${ips[$j]}" >/dev/null 2>&1; then
        printf '%s PASS %s -> %s\n' "$(date +%H:%M:%S)" "${names[$i]}" "${names[$j]}"
      else
        printf '%s FAIL %s -> %s\n' "$(date +%H:%M:%S)" "${names[$i]}" "${names[$j]}"
      fi
    done
  done
  if ((r < rounds)); then sleep "$interval"; fi
done
