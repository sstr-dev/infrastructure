# Network IP Usage

This document tracks the configured usage of the `10.0.60.0/24` and `10.0.69.0/24` networks across my repository.

- `10.0.60.0/24`: primary cluster/internal/server network
- `10.0.69.0/24`: secondary service/LB network

## Service and Gateway IPs

| IP           | Cluster | Network   | Type       | Name                     | Purpose                                     |
|--------------|---------|-----------|------------|--------------------------|---------------------------------------------|
| `10.0.60.50` | `casa`  | `servers` | service IP | `LB_V4_NGINX_INTERNAL`   | internal NGINX service IP                   |
| `10.0.60.51` | `casa`  | `servers` | gateway IP | `LB_V4_K8S_GATEWAY`      | Kubernetes gateway IP                       |
| `10.0.60.52` | `casa`  | `servers` | gateway IP | `LB_V4_GATEWAY_INTERNAL` | internal gateway IP                         |
| `10.0.60.53` | `casa`  | `servers` | service IP | `LB_V4_MARIADB`          | MariaDB service IP                          |
| `10.0.60.55` | `main`  | `servers` | gateway IP | `envoy-internal`         | internal Envoy Gateway service IP           |
| `10.0.60.56` | `main`  | `servers` | service IP | `postgres-lb`            | database load balancer service IP           |
| `10.0.60.57` | `main`  | `servers` | service IP | `postgres-timescale-lb`  | timescale database load balancer service IP |
| `10.0.60.58` | `main`  | `servers` | service IP | `postgres-vector-lb`     | vector database load balancer service IP    |
| `10.0.60.59` | `main`  | `servers` | service IP | `forgejo`                | forgejo git load balancer service IP        |
| `10.0.60.60` | `main`  | `servers` | service IP | `mariadb`                | mariadb load balancer service IP            |
| `10.0.69.50` | `casa`  | `service` | gateway IP | `LB_V4_GATEWAY_MAIN`     | main gateway IP                             |
| `10.0.69.51` | `casa`  | `service` | gateway IP | `LB_V4_GATEWAY_BASE`     | base gateway IP                             |
| `10.0.69.52` | `casa`  | `service` | gateway IP | `LB_V4_GATEWAY_DEV`      | dev gateway IP                              |
| `10.0.69.53` | `casa`  | `service` | gateway IP | `LB_V4_GATEWAY_L4`       | L4 gateway IP                               |
| `10.0.69.54` | `casa`  | `service` | service IP | `LB_V4_SHARED`           | shared service IP                           |
| `10.0.69.55` | `main`  | `service` | gateway IP | `envoy-external`         | external Envoy Gateway service IP           |
| `10.0.69.56` | `main`  | `service` | gateway IP | `envoy-public`           | public Envoy Gateway service IP             |
| `10.0.69.60` | `casa`  | `service` | service IP | `LB_V4_JELLIFIN`         | Jellyfin service IP                         |
| `10.0.69.60` | `casa`  | `service` | service IP | `LB_V4_SMB`              | SMB service IP                              |

## Main Cluster Nodes and VIPs

| IP            | Type    | Name                | Purpose                      |
|---------------|---------|---------------------|------------------------------|
| `10.0.60.1`   | gateway | `main-gateway`      | default gateway              |
| `10.0.60.100` | VIP     | `reserved-lb`       | reserved alternate access IP |
| `10.0.60.200` | VIP     | `control-plane-vip` | shared Kubernetes API VIP    |
| `10.0.60.201` | node IP | `cp01`              | control plane node           |
| `10.0.60.202` | node IP | `cp02`              | control plane node           |
| `10.0.60.203` | node IP | `cp03`              | control plane node           |
| `10.0.60.204` | node IP | `wk01`              | worker primary NIC           |
| `10.0.60.205` | node IP | `wk02`              | worker primary NIC           |
| `10.0.60.206` | node IP | `wk03`              | worker primary NIC           |
| `10.0.69.204` | node IP | `wk01-secondary`    | worker secondary NIC         |
| `10.0.69.205` | node IP | `wk02-secondary`    | worker secondary NIC         |
| `10.0.69.206` | node IP | `wk03-secondary`    | worker secondary NIC         |

## Notes

- `casa` is planned for removal.
- Reserved `servers` IPs from `casa`: `10.0.60.50` to `10.0.60.53`
- Reserved `service` IPs from `casa`: `10.0.69.50` to `10.0.69.54`
- Additional reserved `service` IP from `casa`: `10.0.69.60`
