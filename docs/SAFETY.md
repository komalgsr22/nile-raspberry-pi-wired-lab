# Safety and scope

- **Only test local lab namespaces** or switches/networks you own or are explicitly authorized to assess.
- The scripts in `scripts/` deliberately avoid attaching `wlan0`, the management connection, or physical `eth0` to the virtual bridge.
- Read scripts before executing; they use root privileges to create/delete Linux network devices. Do not run cleanup if another project has reused the same dedicated lab object names (`br-lab`, `veth-victor`, `veth-sam`, `veth-amy`, `veth-suzy` or namespaces).
- Do not run rogue-DHCP services, active scans, or loop-generation tools on apartment, production, or customer networks without an approved plan.
- Avoid storing credentials, wireless passwords, private IP ranges from real customer environments, raw logs with secrets, or identifiable customer details in GitHub.
- The current `10.240.77.0/24` network is an intentionally separate illustrative local subnet.
- The runtime state is volatile: namespaces, veths, IPs and bridges created with `ip` normally disappear after reboot unless automated at startup.
- Scripts are newly authored; review and test before using in any production-adjacent environment.
- `sudo bash scripts/cleanup-local-lab.sh` removes the named virtual lab only; it does not manage physical Nile ports or switch configuration.
