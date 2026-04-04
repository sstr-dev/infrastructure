# Namespace: `network`

This namespace contains ingress, gateway, DNS, tunnel, and network-edge related services.

## Components

| Application | Description | Links |
|-------------|-------------|-------|
| [certificates](./certificates/) | Certificate and network-adjacent routing resources | [Website](https://cert-manager.io) |
| [cloudflare-tunnel](./cloudflare-tunnel/) | Outbound tunnel integration with Cloudflare Edge | [Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) |
| [echo](./echo/) | Simple echo service for connectivity and routing tests | [GitHub](https://github.com/ealen/echo-server) |
| [envoy-gateway](./envoy-gateway/) | Gateway API implementation built on Envoy | [Website](https://gateway.envoyproxy.io) [GitHub](https://github.com/envoyproxy/gateway) |
| [external-dns](./external-dns/) | DNS record automation from Kubernetes resources | [GitHub](https://github.com/kubernetes-sigs/external-dns) |
| [external-services](./external-services/) | Representations for services that live outside the cluster | - |
| [nginx](./nginx/) | NGINX-based ingress or reverse proxy resources | [Website](https://nginx.org) |
| [smtp-relay](./smtp-relay/) | SMTP relay service resources | - |
| [unifi-dns](./unifi-dns/) | UniFi DNS integration resources | [GitHub](https://github.com/kashalls/external-dns-unifi-webhook) |

