# Lab evidence: observed versus not yet performed

**Date:** 2026-11-14. **System:** Raspberry Pi 5, Debian 13 ARM64. **Boundary:** local Linux virtual network; no Nile switch.

| ID | Scenario | Recorded outcome | Status |
|---|---|---|---|
| T01 | List named namespaces | Victor, Suzy, Amy, Sam shown | PASS |
| T02 | Inspect client virtual NICs | Four client `eth0` ports UP, MACs `:01` to `:04` | PASS |
| T03 | Inspect static addresses | `10.240.77.11–14/24` | PASS |
| T04 | Inspect bridge membership | All four veth host ends `master br-lab state forwarding` | PASS |
| T05 | Victor → Sam, before isolation | 4 sent, 4 received, 0% packet loss, 0.050 ms average RTT | PASS |
| T06 | Victor ARP for Sam | `10.240.77.12 dev eth0 lladdr 02:77:00:00:00:02 STALE` | PASS |
| T07 | Inspect isolation settings | All four client ports show `isolated on` | PASS |
| T08 | Victor → Sam, after isolation | 4 sent, 0 received, 100% loss | PASS: blocked locally |
| T09 | Victor → Amy, after isolation | 1 sent, 0 received; interrupted | INCOMPLETE |
| T10 | Victor → Suzy, after isolation | No completed statistics supplied | NOT VERIFIED |
| T11 | Disable isolation and run all-pairs simulator | Commands supplied; no recorded output | PENDING |
| T12 | Eight upstream Nile tools installed / tested | Not done | PENDING |
| T13 | Four distinct Nile physical ports | No adapters/switch attached | PENDING |
| T14 | Nile authentication / Trust Engine allow and deny | Not done | PENDING |

### Actual ping transcript excerpt

```text
PING 10.240.77.12 (10.240.77.12) 56(84) bytes of data.
64 bytes from 10.240.77.12: icmp_seq=1 ttl=64 time=0.105 ms
64 bytes from 10.240.77.12: icmp_seq=2 ttl=64 time=0.039 ms
64 bytes from 10.240.77.12: icmp_seq=3 ttl=64 time=0.030 ms
64 bytes from 10.240.77.12: icmp_seq=4 ttl=64 time=0.029 ms
4 packets transmitted, 4 received, 0% packet loss
rtt min/avg/max/mdev = 0.029/0.050/0.105/0.031 ms
```

After port isolation:

```text
veth-victor ... master br-lab ... isolated on
veth-sam    ... master br-lab ... isolated on
veth-amy    ... master br-lab ... isolated on
veth-suzy   ... master br-lab ... isolated on
4 packets transmitted, 0 received, 100% packet loss  # Victor -> Sam
```

**Interpretation:** Linux bridge port isolation works as configured in the local experiment; it does NOT establish Nile Trust policy behavior. Never infer application availability from ping alone.
