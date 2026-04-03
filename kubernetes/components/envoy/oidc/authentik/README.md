## Usage

Wrappers:

- [`main`](main/kustomization.yaml): uses `${SECRET_MAIN_DOMAIN_NAME}`
- [`base`](base/kustomization.yaml): uses `${SECRET_DOMAIN}`
- [`dev`](dev/kustomization.yaml): uses `${SECRET_DEV_DOMAIN}`
- [`game`](game/kustomization.yaml): uses `${SECRET_GAME_DOMAIN}`
- [`internal`](internal/kustomization.yaml): uses `${DOMAIN}`

Requirements:

- `APP`, `APP_UPPER`

Optional substitutions:

- `CLUSTER` defaults to the current cluster-specific substitution source
- `SECRET_STORE` defaults to `vault-backend`
- `EXT_AUTH_GROUP` defaults to `gateway.networking.k8s.io`
- `EXT_AUTH_KIND` defaults to `HTTPRoute`
- `EXT_AUTH_TARGET` defaults to `${APP}`
- `APP_SLUG` defaults to `${APP}`
- `LOGOUT_PATH` defaults to `/logout`
- `SUBDOMAIN` defaults to `${APP}`
- `GATUS_SUBDOMAIN` defaults to `${SUBDOMAIN}` and overrides the redirect host label

Wrapper-specific domain variables:

- `main` uses `${SECRET_MAIN_DOMAIN_NAME}`
- `base` uses `${SECRET_DOMAIN}`
- `dev` uses `${SECRET_DEV_DOMAIN}`
- `game` uses `${SECRET_GAME_DOMAIN}`
- `internal` uses `${DOMAIN}`

Secret backend values:

- `${CLUSTER}/${APP}` must contain `${APP_UPPER}_OIDC_CLIENT_ID`
- `${CLUSTER}/${APP}` must contain `${APP_UPPER}_OIDC_CLIENT_SECRET`

Example:

```yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: &app appname
spec:
  components:
    - ../../../../components/envoy/oidc/authentik/main
  postBuild:
    substitute:
      APP: *app
      APP_UPPER: APPNAME
    substituteFrom:
      - kind: ConfigMap
        name: cluster-settings
      - kind: Secret
        name: cluster-secrets
```
