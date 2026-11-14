# Roadmap: Pi virtual clients → four Nile physical switch ports

## Phase A — local experiment (completed partially)

Create four namespaces and corresponding veth interfaces; attach to a local Linux bridge and verify ARP/ICMP traffic. Toggle Linux bridge isolation on/off to learn local switching. **Do not claim this is a Nile Trust test.**

## Phase B — reproducibility (current)

Verify `scripts/setup-local-lab.sh`, `scripts/check-lab.sh`, `scripts/traffic-simulator.sh`, and `scripts/cleanup-local-lab.sh` on the Pi. Keep snapshot of output; test script idempotence and cleanup. No system startup service is installed yet.

## Phase C — prepare hardware (future)

Acquire three supported USB-to-Ethernet adapters, with individual RJ45 jacks. Keep Pi's Wi-Fi `wlan0` for SSH. Plug adapters into Pi USB ports and use `ip -br link`, `nmcli device status`, and `lsusb` to identify adapters *before* changing any interfaces. Do not assume interface names; avoid altering SSH's network path.

## Phase D — physical one-to-one mapping (future)

| Namespace | Physical Pi interface | Switch uplink |
|---|---|---|
| Victor | Built-in `eth0` | Authorized Nile switch port 1 |
| Sam | USB Ethernet adapter A (name TBD) | Port 2 |
| Amy | USB Ethernet adapter B (name TBD) | Port 3 |
| Suzy | USB Ethernet adapter C (name TBD) | Port 4 |

Safely delete only local training veth pairs **when ready**. Move or otherwise attach **one physical Ethernet interface per namespace** with compatible NetworkManager and udev handling. Do not bridge the four wired test interfaces locally.

## Phase E — actual Nile tests (future)

1. Verify physical link and per-port endpoint discovery.
2. Confirm expected preauthentication/onboarding traffic and deny state based on the actual configured Nile system.
3. Test the supported 802.1X or other Nile-approved authentication mechanism per device; record identities and evidence.
4. Confirm authorization/Trust policy is assigned as expected.
5. Deny Victor → Sam under an explicit test policy.
6. Permit Victor → Sam under an explicit test policy and prove traffic traverses the Nile-controlled network path.
7. Revoke permission and verify denial.
8. Document failure modes, timing, DHCP/DNS, traffic capture and cleanup.

**Caution:** Port-local MAC identities, endpoint onboarding, authentication sessions and Trust policy are not interchangeable. Results depend on Nile hardware, firmware and configurations.

## Why not one cable and four MACs?

That approach can potentially expose distinct source MAC addresses behind one switch port but local bridge forwarding may bypass Nile; with bridge port isolation, a conventional switch still normally does not hairpin same-port traffic back to the other endpoint. Four physical ports are a more defensible topology for allow/deny testing.
