## Overview

This directory contains reusable Envoy Gateway auth components for `HTTPRoute` targets.

| Component                                      | Method        | Purpose                                                  | Requirements                                           | Notes                                                                                 |
|------------------------------------------------|---------------|----------------------------------------------------------|--------------------------------------------------------|---------------------------------------------------------------------------------------|
| [`basic`](./basic/README.md)                   | Basic Auth    | Protect a route with username/password                   | `APP`, `CLUSTER`, secret backend entry with `htpasswd` | Uses `ExternalSecret`; SHA `htpasswd` entries                                         |
| [`ext-auth`](./ext-auth/README.md)             | External Auth | Delegate auth to an external service                     | `APP`                                                  | Defaults to Authentik Outpost; backend and path are overridable                       |
| [`ext-auth/two`](./ext-auth/README.md)         | External Auth | Create a second ext auth `SecurityPolicy`                | `APP` plus optional `*_2` vars                         | Falls back from `_2` vars to shared ext-auth vars, then defaults                      |
| [`oidc/authentik`](./oidc/authentik/README.md) | OIDC          | Native Envoy OIDC login flow using Authentik             | `APP`, `APP_UPPER`, Authentik client secret in backend | Wrapper variants: `main`, `base`, `dev`, `game`, `internal`                           |
| [`oauth`](./oauth/)                            | OIDC          | Simple OIDC `SecurityPolicy` using `id.${SECRET_DOMAIN}` | `APP`, `${SECRET_DOMAIN}`, `${APP}-oidc-secret`        | Legacy/simple variant; prefer `oidc/authentik` for new Authentik-based configurations |

## Common Pattern

Most components target `${APP}` as an `HTTPRoute` by default and are intended to be added via Flux `Kustomization.spec.components`.

Example:

```yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: &app whoami
spec:
  components:
    - ../../../../components/envoy/basic
  postBuild:
    substitute:
      APP: *app
    substituteFrom:
      - kind: ConfigMap
        name: cluster-settings
      - kind: Secret
        name: cluster-secrets
```

## Notes

- `basic` and `oidc/authentik` also create or consume Secrets, so they need secret backend data in addition to the `SecurityPolicy`
