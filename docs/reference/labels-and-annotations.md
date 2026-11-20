# Labels & Annotations

Labels and annotations that actually *do* something in the cluster, i.e. something selects on
them or reads them. The usual chart/app metadata (`app.kubernetes.io/*`, `helm.sh/*`, …) isn't listed.

## Our own keys: `<area>.sstr.dev/<key>`

We own `sstr.dev`, so nothing upstream will ever clash with it. The `<area>` part just tells
you who reads the key:

| Area | Read by | Example |
|------|---------|---------|
| `helm.sstr.dev` | Flux HelmRelease patches in `clusters/*/apps.yaml` | `helm.sstr.dev/upgrade-strategy: retry` |
| `kyverno.sstr.dev` | Kyverno policies | `kyverno.sstr.dev/ignore: "true"` |
| `route.sstr.dev` | set by Kyverno on HTTPRoutes | `route.sstr.dev/exposure: internal` |
| `network.sstr.dev` | Cilium (L2, LB-IPAM, NetworkPolicies) | `network.sstr.dev/l2-segment: servers` |
| `grafana.sstr.dev` | grafana-operator | `grafana.sstr.dev/instance: grafana` |
| `flux.sstr.dev` | Flux Kustomization patches | `flux.sstr.dev/component: postgres-init` |

A few rules of thumb:

- Something selects on it → **label**. Only read as a value (YAML, lists, text) → **annotation**.
- Lowercase values, booleans as `"true"` / `"false"`.
- No more keys without a prefix, no `home.arpa`, and don't make up keys under someone else's
  domain (`kyverno.io/…`, `cilium/…`).
- New key? Add it here.

### What's in use

| Key | On | What it does |
|-----|----|--------------|
| `helm.sstr.dev/upgrade-strategy: retry` | HelmRelease (paperless) | No rollback on failed upgrades, retry instead, 30m timeout. For apps that migrate their DB on start. |
| `kyverno.sstr.dev/ignore: "true"` | Pod | Skips `add-safe-to-evict` and `remove-cpu-limit` |
| `route.sstr.dev/exposure` | HTTPRoute | Set by Kyverno: `external` / `public` / `internal`, based on the gateway |
| `route.sstr.dev/gateway` | HTTPRoute | Set by Kyverno: name of that gateway |
| `network.l2.cilium/segment` | LB Services | Which `CiliumL2AnnouncementPolicy` announces the IP (`servers` / `services`). Should become `network.sstr.dev/…` |
| `network.l2.cilium/lan69` | Nodes (Talos) | Nodes that announce on lan69. Moves together with the one above |
| `dashboards: grafana` | Grafana + almost all dashboards/datasources | Which Grafana instance picks them up |
| `grafana.internal/instance: grafana` | Grafana + 5 dashboards | Same thing as `dashboards: grafana`, should be merged into one |


