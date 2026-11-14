# Step-by-step journal: actual Raspberry Pi 5 lab (November 14, 2026)

This is a chronological reconstruction of the observed lab, with working commands and explanations. It records *what happened*, not claims of physical Nile testing.

## 0. Pi setup and access

Raspberry Pi OS based on Debian GNU/Linux 13 (trixie), ARM64. After correcting the Wi-Fi SSID in Raspberry Pi Imager, the Mac reached `komalgsr.local` at `10.0.0.108`. SSH succeeded using the configured Linux username. The SSH host-key warning was consistent with a re-imaged OS; verify fingerprints before accepting a changed key.

```bash
ssh komalgsr@komalgsr.local  # Mac -> Pi, uses Pi password
hostnamectl                  # OS, architecture and hostname
ip -br addr                  # brief network interface IP addresses
ip -br link                  # link status, MAC and flags
```

Previously observed: physical `eth0` enabled but `NO-CARRIER` with no IPv4; `wlan0` up on apartment Wi-Fi. No wired switch attached.

## 1. Create isolated network environments

```bash
sudo ip netns add victor
sudo ip netns add sam
sudo ip netns add amy
sudo ip netns add suzy
ip netns list
```

The user originally experimented with Bob, then changed names. The final list showed `victor`, `suzy`, `amy`, `sam`. The `id` annotations are namespace indices, not Nile client IDs.

Each namespace initially had only `lo DOWN`, a local loopback interface. A namespace is *not* a separate OS or physical machine.

## 2. Virtual Ethernet cables

A `veth` pair has two ends: the Pi-side endpoint stays in the default network namespace; the other moves into a named client namespace.

Example performed manually for Victor:

```bash
sudo ip link add veth-victor type veth peer name veth-victor-ns
sudo ip link set veth-victor-ns netns victor
sudo ip netns exec victor ip link set veth-victor-ns name eth0
sudo ip netns exec victor ip link set dev eth0 address 02:77:00:00:00:01
sudo ip netns exec victor ip link set dev eth0 up
sudo ip netns exec victor ip -br link
```

The other three clients followed the same pattern, using `veth-sam`, `veth-amy`, `veth-suzy`, and MAC suffixes `:02`, `:03`, `:04`.

**Why different MACs?** Distinct locally administered MACs help us observe separate endpoint identities in packet captures; they do not by themselves authenticate anyone.

## 3. Assign lab IPv4 addresses

```bash
sudo ip netns exec victor ip addr replace 10.240.77.11/24 dev eth0
sudo ip netns exec sam    ip addr replace 10.240.77.12/24 dev eth0
sudo ip netns exec amy    ip addr replace 10.240.77.13/24 dev eth0
sudo ip netns exec suzy   ip addr replace 10.240.77.14/24 dev eth0
for client in victor sam amy suzy; do
  echo "===== $client ====="
  sudo ip netns exec "$client" ip -br addr show eth0
done
```

**Observed:** all four `eth0` interfaces UP with the expected `10.240.77.11–14/24` addresses and IPv6 link-local addresses. The IPs were manually assigned; **DHCP was not configured or tested**.

## 4. Create a local software switch and connect virtual cables

```bash
sudo ip link add br-lab type bridge
sudo ip link set br-lab up
for client in victor sam amy suzy; do
  sudo ip link set "veth-$client" master br-lab
  sudo ip link set "veth-$client" up
done
bridge link show
```

**Observed:** four entries such as `veth-victor@if4 ... master br-lab state forwarding`. Initially `bridge link show` returned nothing when no ports had been attached. `ip -d link show br-lab` confirmed bridge existence even without member ports.

**Important:** This local Linux bridge is *only for local learning*. Never attach `wlan0` or a physical `eth0` to an experimental bridge on an unapproved network.

## 5. Test normal connectivity

```bash
sudo ip netns exec victor ping -c 4 10.240.77.12
sudo ip netns exec victor ip neigh show
```

**Actual output:** 4 transmitted, 4 received, 0% loss; min/avg/max = 0.029 / 0.050 / 0.105 ms. Victor's neighbor table showed `10.240.77.12 dev eth0 lladdr 02:77:00:00:00:02 STALE`. This proves local IP connectivity and ARP resolution through the virtual bridge.

## 6. Enable local bridge port isolation

```bash
for client in victor sam amy suzy; do
  sudo bridge link set dev "veth-$client" isolated on
done
bridge -d link show
sudo ip netns exec victor ping -c 4 -W 2 10.240.77.12
```

**Observed:** all four bridge members reported `isolated on`. Victor -> Sam: 4 transmitted, 0 received, 100% loss. Victor -> Amy was interrupted after one unanswered probe. Victor -> Suzy's final statistics were not supplied. **No Nile policy was involved.**

## 7. Re-enable local forwarding and simulate traffic

The following commands were provided as the next exercise; their **execution has not yet been confirmed**:

```bash
for client in victor sam amy suzy; do
  sudo bridge link set dev "veth-$client" isolated off
done
bridge -d link show

# Existing user-facing one-off loop example
for source in victor sam amy suzy; do
  for destination in victor sam amy suzy; do
    if [ "$source" != "$destination" ]; then
      case "$destination" in
        victor) ip=10.240.77.11 ;;
        sam) ip=10.240.77.12 ;;
        amy) ip=10.240.77.13 ;;
        suzy) ip=10.240.77.14 ;;
      esac
      sudo ip netns exec "$source" ping -c 2 -W 1 "$ip"
    fi
  done
done
```

The repository now has reusable bounded `scripts/traffic-simulator.sh` and a one-command `scripts/setup-local-lab.sh`; automated scripts must still be verified on the actual Pi.

## 8. Physical adapter discovery

`lsusb` displayed `343c:0000 USB Type-C Digital AV Adapter`, not a recognized USB Ethernet interface. The `ip -br link` output showed **no new physical Ethernet adapter** beyond built-in `eth0`. Three compatible USB-to-Ethernet adapters are planned for future Nile multi-port experiments.

## 9. Why we revised the architecture

We initially explored **four MACs through one physical switch port**. But a local bridge can forward traffic without visiting Nile, and an external switch typically cannot send permitted frames back out the ingress port. So a single-port topology may show multiple MACs but **cannot be assumed to validate inter-client allow and deny policies**.

The revised future topology is one Pi, **four separate physical connections to four Nile switch ports**, one per namespace. No configuration for that topology was executed.

## Quick troubleshooting

- `ip netns list` empty: namespaces not created, or Pi rebooted.
- `ip -br link` `NO-CARRIER`: physical Ethernet link not detected; this is normal without a cable.
- `ip neigh` says `STALE`: mapping exists, not recently verified; doesn't necessarily mean a failure.
- Ping fails under `isolated on`: expected for directly connected isolated bridge ports.
- SSH fails after switching Wi-Fi: ensure Mac and Pi are reachable on same network; don't assume apartment Wi-Fi allows client-to-client connections.
- Manual lab objects vanish after reboot: rerun the controlled local setup script.
