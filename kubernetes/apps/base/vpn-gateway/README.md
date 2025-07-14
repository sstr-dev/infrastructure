# 🗂️ Namespace: `vpn-gateway`

This namespace contains networking components used to route traffic from selected pods through VPNs or isolated egress paths.

---

## 📦 Included Components

| Application                                   | Description                                                | Links                                                                               |
|-----------------------------------------------|------------------------------------------------------------|-------------------------------------------------------------------------------------|
| [**downloads-gateway**](./downloads-gateway/) | Pod-level egress gateway for policy-based routing via VPNs | [GitHub](https://github.com/angelnu/helm-charts/tree/main/charts/downloads-gateway) |

---

## 📎 Notes

- This gateway enables selected pods to route their traffic through a VPN tunnel (e.g. Mullvad).
- Based on Linux routing policies and iptables/ip rules within a sidecar or network namespace.
- Useful for downloaders or tools requiring geo-specific access (e.g. streaming APIs).
