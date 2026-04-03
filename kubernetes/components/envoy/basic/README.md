## Usage

Requirements:

- `APP`
- `CLUSTER`

Optional substitutions:

- `EXT_AUTH_GROUP` defaults to `gateway.networking.k8s.io`
- `EXT_AUTH_KIND` defaults to `HTTPRoute`
- `EXT_AUTH_TARGET` defaults to `${APP}`
- `SECRET_STORE` defaults to `vault-backend`
- `BASIC_AUTH_SECRET_KEY` defaults to `htpasswd`

Expected secret data:

```yaml
htpasswd: "user:$apr1$hashed-password"
```

The `ExternalSecret` reads from `${CLUSTER}/${APP}` and writes a Secret named `${APP}-basic-auth-secret`
with a `.htpasswd` key for Envoy Gateway basic auth.

Note:

- Only SHA hash algorithm is supported for now
- Generate entries with `htpasswd -s`

Example to create the secret value:

```bash
htpasswd -nbs myuser 'super-secret-password'
```

Example output:

```text
myuser:{SHA}W6ph5Mm5Pz8GgiULbPgzG37mj9g=
```

Store that value in your secret backend at `${CLUSTER}/${APP}` under the `htpasswd` key:

```yaml
htpasswd: "myuser:{SHA}W6ph5Mm5Pz8GgiULbPgzG37mj9g="
```

Example for more than one user:

```bash
{
  htpasswd -nbs myuser 'super-secret-password'
  htpasswd -nbs admin 'another-secret-password'
}
```

Store both lines in the same `htpasswd` value:

```yaml
htpasswd: |
  myuser:{SHA}W6ph5Mm5Pz8GgiULbPgzG37mj9g=
  admin:{SHA}exampleexampleexampleexampleexample=
```

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
