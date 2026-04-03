## Usage

This component creates an Envoy Gateway `SecurityPolicy` with `extAuth`.

Default backend:

- Authentik Outpost service `ak-outpost-proxy`
- Namespace `security`
- Port `9000`
- Path `/outpost.goauthentik.io/auth/envoy`

Requirements:

- `APP`

Default target ref variables:

- `EXT_AUTH_GROUP` defaults to `gateway.networking.k8s.io`
- `EXT_AUTH_KIND` defaults to `HTTPRoute`
- `EXT_AUTH_TARGET` defaults to `${APP}`

Default backend variables:

- `EXT_AUTH_BACKEND_NAME` defaults to `ak-outpost-proxy`
- `EXT_AUTH_BACKEND_NAMESPACE` defaults to `security`
- `EXT_AUTH_BACKEND_PORT` defaults to `9000`
- `EXT_AUTH_PATH` defaults to `/outpost.goauthentik.io/auth/envoy`

`two/` variant:

- creates a second `SecurityPolicy` named `${APP}-2`
- targets `EXT_AUTH_TARGET_2`
- can reuse the default backend variables
- or override them per policy with `_2` variables

`two/` target ref variables:

- `EXT_AUTH_GROUP_2` defaults to `gateway.networking.k8s.io`
- `EXT_AUTH_KIND_2` defaults to `HTTPRoute`
- `EXT_AUTH_TARGET_2` defaults to `${APP}`

`two/` backend fallback order:

- `EXT_AUTH_BACKEND_NAME_2` or `EXT_AUTH_BACKEND_NAME` or `ak-outpost-proxy`
- `EXT_AUTH_BACKEND_NAMESPACE_2` or `EXT_AUTH_BACKEND_NAMESPACE` or `security`
- `EXT_AUTH_BACKEND_PORT_2` or `EXT_AUTH_BACKEND_PORT` or `9000`
- `EXT_AUTH_PATH_2` or `EXT_AUTH_PATH` or `/outpost.goauthentik.io/auth/envoy`

Example:

```yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: &app whoami
spec:
  components:
    - ../../../../components/envoy/ext-auth
  postBuild:
    substitute:
      APP: *app
    substituteFrom:
      - kind: ConfigMap
        name: cluster-settings
      - kind: Secret
        name: cluster-secrets
```

Example with custom backend:

```yaml
postBuild:
  substitute:
    APP: myapp
    EXT_AUTH_BACKEND_NAME: my-auth-service
    EXT_AUTH_BACKEND_NAMESPACE: auth
    EXT_AUTH_BACKEND_PORT: "8080"
    EXT_AUTH_PATH: /check
```

Example with `two/` and separate backend:

```yaml
spec:
  components:
    - ../../../../components/envoy/ext-auth
    - ../../../../components/envoy/ext-auth/two
  postBuild:
    substitute:
      APP: myapp
      EXT_AUTH_TARGET: myapp
      EXT_AUTH_TARGET_2: myapp-api
      EXT_AUTH_BACKEND_NAME_2: my-second-auth-service
      EXT_AUTH_BACKEND_NAMESPACE_2: auth
      EXT_AUTH_BACKEND_PORT_2: "8081"
      EXT_AUTH_PATH_2: /auth/api
```

Notes:

- For Authentik, create a Proxy Provider and the required `ReferenceGrant` in `security/authentik/references` for the target namespace

