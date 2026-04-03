## Overview

This directory contains reusable Envoy Gateway auth components for `HTTPRoute` targets.

| Component                                      | Method        | Purpose                                                              | Best for                                           | Requirements                                                  | Notes                                                                                      |
|------------------------------------------------|---------------|----------------------------------------------------------------------|----------------------------------------------------|---------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| [`basic`](./basic/README.md)                   | Basic Auth    | Protect a route with username/password                               | Small internal tools, simple shared access         | `APP`, `CLUSTER`, secret backend entry with `htpasswd`        | Uses `ExternalSecret`; currently only SHA `htpasswd` entries are documented/supported here |
| [`ext-auth`](./ext-auth/README.md)             | External Auth | Delegate auth to an external service                                 | Authentik Outpost and other ext auth backends      | `APP`                                                         | Defaults to Authentik Outpost, but backend and path are overridable                        |
| [`ext-auth/two`](./ext-auth/README.md)         | External Auth | Attach a second ext auth policy with separate target/backend options | Apps with two routes or different auth entrypoints | `APP` plus optional `*_2` vars                                | Falls back from `_2` vars to shared ext-auth vars, then defaults                           |
| [`oidc/authentik`](./oidc/authentik/README.md) | OIDC          | Native Envoy OIDC login flow using Authentik                         | Browser-facing apps with SSO                       | `APP`, `APP_UPPER`, Authentik client secret in secret backend | Has wrapper variants for `main`, `base`, `dev`, `game`, `internal`                         |
| [`oauth`](./oauth/)                            | OIDC          | Older/simple OIDC `SecurityPolicy` component                         | Legacy/simple setups using `id.${SECRET_DOMAIN}`   | `APP`, `${SECRET_DOMAIN}`, `${APP}-oidc-secret`               | Less flexible than `oidc/authentik`; prefer `oidc/authentik` for new Authentik setups      |

## Choosing

| If you want...                                          | Use...                                                                        |
|---------------------------------------------------------|-------------------------------------------------------------------------------|
| Simple username/password gate in front of an app        | [`basic`](./basic/README.md)                                                  |
| Delegated auth via Authentik Outpost                    | [`ext-auth`](./ext-auth/README.md)                                            |
| Two different ext auth policies for one app             | [`ext-auth`](./ext-auth/README.md) and [`ext-auth/two`](./ext-auth/README.md) |
| Native OIDC login with Authentik                        | [`oidc/authentik`](./oidc/authentik/README.md)                                |
| Existing/legacy OIDC policy using `id.${SECRET_DOMAIN}` | [`oauth`](./oauth/)                                                           |

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
