# ntfy

This deployment provides a self-hosted [`ntfy`](https://ntfy.sh) instance in the `self-hosted` namespace.

The application is exposed at `https://ntfy.${SECRET_MAIN_DOMAIN_NAME}` and is configured with:

- login enabled
- mandatory authentication for the UI and API
- default topic access set to `deny-all`
- persistent storage mounted at `/data`
- PostgreSQL connection injected through `ExternalSecret`

## Files

- [`helmrelease.yaml`](/home/sst/sstr-dev/infrastructure/kubernetes/apps/base/self-hosted/ntfy/helmrelease.yaml)
- [`externalsecret.yaml`](/home/sst/sstr-dev/infrastructure/kubernetes/apps/base/self-hosted/ntfy/externalsecret.yaml)
- [`kustomization.yaml`](/home/sst/sstr-dev/infrastructure/kubernetes/apps/base/self-hosted/ntfy/kustomization.yaml)

## First Start

1. Apply or reconcile the Flux `Kustomization` for `ntfy`.
2. Wait until the pod is running:

```bash
kubectl -n self-hosted get pods -l app.kubernetes.io/name=ntfy
```

3. Open the public URL:

```text
https://ntfy.<your-domain>
```

Because `NTFY_REQUIRE_LOGIN=true` and `NTFY_AUTH_DEFAULT_ACCESS=deny-all`, no useful access is available until at least one user exists.

## Create the First Admin User

Create the initial admin account inside the running container:

```bash
kubectl -n self-hosted exec -it deploy/ntfy -- ntfy user add --role=admin <username>
```

The command prompts for a password interactively.

Admins automatically have read/write access to all topics, so no extra ACL entry is required.

You can then log in via the web UI or use the same credentials with the mobile app / API.

## Create Additional Users

Create a regular user:

```bash
kubectl -n self-hosted exec -it deploy/ntfy -- ntfy user add <username>
```

Grant access to one topic:

```bash
kubectl -n self-hosted exec deploy/ntfy -- ntfy access <username> mytopic rw
```

Grant read-only access to a topic pattern:

```bash
kubectl -n self-hosted exec deploy/ntfy -- ntfy access <username> "alerts-*" ro
```

Useful values:

- `rw`: read and write
- `ro`: read only
- `wo`: write only
- `deny`: explicit deny

## User Management

List users:

```bash
kubectl -n self-hosted exec deploy/ntfy -- ntfy user list
```

Change a password:

```bash
kubectl -n self-hosted exec -it deploy/ntfy -- ntfy user change-pass <username>
```

Change the role:

```bash
kubectl -n self-hosted exec deploy/ntfy -- ntfy user change-role <username> admin
```

Show ACL entries:

```bash
kubectl -n self-hosted exec deploy/ntfy -- ntfy access
kubectl -n self-hosted exec deploy/ntfy -- ntfy access <username>
```

## Operational Notes

- Admin users automatically have full access to all topics. Regular users need ACL entries via `ntfy access`.
- The deployment uses a read-only root filesystem, so persistent ntfy state must remain under `/data`.
- `NTFY_AUTH_FILE` is not explicitly configured in this manifest. If user or ACL data should be pinned to the persistent volume with certainty, set it explicitly to a file below `/data`.
- SMTP is configured, so email-related features can be enabled once the ntfy app itself is set up accordingly.
- Database credentials come from Vault via `ExternalSecret` key `${CLUSTER}/ntfy`.

## Troubleshooting

Check pod logs:

```bash
kubectl -n self-hosted logs deploy/ntfy
```

Open a shell in the container:

```bash
kubectl -n self-hosted exec -it deploy/ntfy -- sh
```

Verify the generated secret exists:

```bash
kubectl -n self-hosted get secret ntfy-secret
```

## References

- https://docs.ntfy.sh/
- https://docs.ntfy.sh/config/
- https://docs.ntfy.sh/publish/
