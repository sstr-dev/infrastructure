# 🗂️ Namespace: `network`

This namespace provides routing, ingress, tunneling, and DNS management services. It is responsible for exposing internal workloads securely and managing domain resolution for external access.

---

## 📦 Included Components

| Application              | Description                                         | Links                                                                                   |
|--------------------------|-----------------------------------------------------|-----------------------------------------------------------------------------------------|
| [**cloudflare-tunnel**](./cloudflare-tunnel/) | Secure outbound tunnel to Cloudflare Edge | [Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)      |
| [**echo**](./echo/)                         | Simple HTTP echo service (for testing)     | [GitHub](https://github.com/Ealenn/Echo-Server)                                         |
| [**envoy-gateway**](./envoy-gateway/)       | Cloud-native API gateway with Envoy core   | [Website](https://gateway.envoyproxy.io) [GitHub](https://github.com/envoyproxy/gateway) |
| [**external-dns**](./external-dns/)         | External DNS controller for Kubernetes     | [GitHub](https://github.com/kubernetes-sigs/external-dns)                              |
| [**external-services**](./external-services/) | Placeholder for externally referenced services | —                                                                                   |
| [**k8s-gateway**](./k8s-gateway/)           | DNS-based Kubernetes Gateway for ingress   | [GitHub](https://github.com/kubernetes-sigs/gateway-api)                                |
| [**nginx**](./nginx/)                       | NGINX Ingress controller or reverse proxy  | [Website](https://nginx.org) [GitHub](https://github.com/nginxinc/kubernetes-ingress)   |

---

## 📎 Notes

- Consider combining `external-dns`, `cloudflare-tunnel`, and `envoy-gateway` for a full edge-routing stack.
- `echo` can be used to verify connectivity, headers, and ingress logic.
- Zone delegation and certificate issuance may tie into `cert-manager`.
