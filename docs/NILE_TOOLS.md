# Eight upstream Nile demo/readiness repositories — review backlog

Source referenced by user: [setup-nile-test-client](https://github.com/austinhawthorne/setup-nile-test-client).

The setup script runs `apt update`, installs dependencies including Python networking utilities, Scapy, FRRouting, FreeRADIUS, DNS utilities, curl and OpenSSL, then uses `sudo pip ... --break-system-packages` for `asciichartpy`/`dhcppython` and clones repositories into the invoking user's home directory.

**Do not execute this installer blindly** on a working Pi: it modifies system packages and bypasses managed-Python safeguards. Download and inspect sources first; use virtual environments where appropriate. Exact functionality of each project requires review of that repository's own code.

| Repository | Intended subject (based on name) | Prerequisite/question before execution | Status |
|---|---|---|---|
| [rogue-dhcp-test](https://github.com/austinhawthorne/rogue-dhcp-test) | Detect or simulate rogue DHCP behavior | Does it *send* DHCP offers? Only authorized isolated lab | Unreviewed |
| [loop-detector](https://github.com/austinhawthorne/loop-detector) | Layer 2 loop detection | Detection-only or generates frames? Never create a production loop | Unreviewed |
| [dot1x-test](https://github.com/austinhawthorne/dot1x-test) | Wired 802.1X/EAP | Supported supplicant, authorized switch port, test credentials/certs | Unreviewed |
| [simple-mcast-test](https://github.com/austinhawthorne/simple-mcast-test) | Multicast connectivity | Group, receiver and sender topology | Unreviewed |
| [simple-airplay](https://github.com/austinhawthorne/simple-airplay) | AirPlay or Bonjour discovery | Does it advertise or discover services? Authorized network only | Unreviewed |
| [net-scan](https://github.com/austinhawthorne/net-scan) | Network device/service discovery | Explicitly scoped target subnet or localhost only | Unreviewed |
| [staticip-test](https://github.com/austinhawthorne/staticip-test) | Static IP connectivity | Avoid disrupting management link / IP conflict | Unreviewed |
| [nile-readiness-test](https://github.com/austinhawthorne/nile-readiness-test) | Deployment readiness checks | Determine tests, destinations and side effects first | Unreviewed |

**Desired future work:** preserve upstream license notices; document per-repository usage/parameters, exact expected traffic, permissions, results and cleanup. This repo does not include third-party source code.
