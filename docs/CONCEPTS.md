# Networking concepts, explained with analogies

| Networking term | Analogy | Technical meaning |
|---|---|---|
| Linux namespace | One employee's separate office | Isolated Linux network stack with its own interfaces, routes, neighbors and sockets |
| veth pair | Two ends of a virtual Ethernet cable | Two linked virtual interfaces; one side in client namespace, one side on Pi host |
| MAC address | Nameplate on the office's network door | Layer 2 interface identifier (configurable/spoofable, not proof of identity) |
| IP address | Office's postal address | Layer 3 address enabling packets to reach a destination |
| ARP | Asking 'Who has office 12?' | IPv4-to-MAC mapping on a local link |
| Linux bridge | Office mailroom | Software Ethernet switch forwarding frames among attached ports |
| Switch FDB | Mailroom delivery directory | MAC-to-port forwarding table |
| ICMP ping | Sending 'Are you there?' postcards | Echo request/reply reachability test |
| Bridge port isolation | Mailroom won't deliver directly between two rooms | Prevents frames forwarding between isolated bridge ports |
| Nile Trust Engine | Building access policy controller | Future real network authorization and enforcement, not simulated by Linux bridge |

## Why MAC *and* IP?

When Victor (`10.240.77.11`) sends to Sam (`10.240.77.12`), Victor first determines from the `/24` subnet that Sam is on the same local network. He asks ARP who owns Sam's IP, then encapsulates the IP packet inside an Ethernet frame addressed to Sam's MAC `02:77:00:00:00:02`. The bridge forwards the frame to Sam's virtual port.

## Why did `STALE` appear in ARP?

After pinging Sam, Victor's neighbor table listed `10.240.77.12 dev eth0 lladdr 02:77:00:00:00:02 STALE`. This means a cached mapping exists but reachability hasn't recently been revalidated; it does not mean the remote device is down.

## Why the first ping succeeded but the later ping failed

Initially all four veth host ends were forwarding on `br-lab`, with bridge isolation disabled. Four Victor-to-Sam pings succeeded. Later each bridge port showed `isolated on`; Linux no longer forwarded directly between isolated ports, and four Victor-to-Sam pings received no replies. The **test demonstrates Linux port isolation**, not Nile Trust Engine.

## Authentication vs authorization

Authentication establishes a client/user identity; authorization determines what traffic that identity can send and receive. In the future Nile test, merely detecting a MAC address or establishing Ethernet link won't prove 802.1X success or Trust policy enforcement. The actual policy and authentication capabilities must be verified for the specific Nile deployment.
