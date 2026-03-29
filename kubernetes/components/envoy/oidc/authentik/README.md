## Usage

Wrappers:

- [`main`](main/kustomization.yaml): uses `${SECRET_MAIN_DOMAIN_NAME}`
- [`base`](base/kustomization.yaml): uses `${SECRET_DOMAIN}`
- [`dev`](dev/kustomization.yaml): uses `${SECRET_DEV_DOMAIN}`
- [`game`](game/kustomization.yaml): uses `${SECRET_GAME_DOMAIN}`
- [`internal`](internal/kustomization.yaml): uses `${DOMAIN}`

Requirements:

- `APP`, `APP_UPPER`

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

