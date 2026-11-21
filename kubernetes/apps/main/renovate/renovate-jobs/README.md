# Renovate jobs

`RenovateJob` resources for the [renovate-operator](https://github.com/mogenius/renovate-operator).

| Job                        | Provider | Schedule | Notes |
|----------------------------|----------|----------|-------|
| [forgejo](./forgejo.yaml)  | Forgejo  | hourly   | Autodiscovers `sstr-dev/*` as bot user `lab-assistant`. |

## Forgejo setup

Renovate runs as the existing bot user `lab-assistant`. Internal sign-in is disabled on
Forgejo, so the token is created with the Forgejo CLI inside the pod.

If the user not exists:

```sh
kubectl -n dev exec -it deploy/forgejo -- forgejo admin user create \
  --username lab-assistant --email renovate@<deine-domain> \
  --random-password --must-change-password=false
```

Use a dedicated token for Renovate, so it can be rotated or revoked without breaking other
tools that also use `lab-assistant`:

```sh
kubectl -n dev exec -it deploy/forgejo -- forgejo admin user generate-access-token \
  --username lab-assistant \
  --token-name renovate-operator \
  --scopes "write:repository,write:issue,read:user,read:organization,read:package" \
  --raw
```

Required scopes:

| Scope                | Why |
|----------------------|-----|
| `write:repository`   | clone, push branches, open/update pull requests |
| `write:issue`        | Dependency Dashboard issue, labels |
| `read:user`          | resolve the bot's own identity (git author, own PRs) |
| `read:organization`  | autodiscover repositories in `sstr-dev` |
| `read:package`       | optional, Forgejo package registry as a datasource |

Repository access: autodiscover only finds repositories `lab-assistant` can write to.
Give the bot **Write** permission on Code, Issues and Pull Requests, either through an
org team (`sstr-dev` → Teams → e.g. `bots`) or as a collaborator per repository.

Repositories without a `renovate.json` get an onboarding PR first.

## Secrets

Vault path `main/renovate-operator` (rendered into `Secret/renovate-forgejo-secret`):

| Key                         | Value |
|-----------------------------|-------|
| `RENOVATE_FORGEJO_TOKEN`    | token from above |
| `RENOVATE_GITHUB_COM_TOKEN` | GitHub PAT without any scopes; used for changelogs and GitHub datasources (rate limit) |

GitHub token: github.com → Settings → Developer settings → Personal access tokens →
Tokens (classic) → *Generate new token (classic)*, **no scopes selected**. It is only used
for anonymous-equivalent reads with a higher rate limit (5000/h instead of 60/h).

Write both keys without touching the existing OIDC keys (`patch`, not `put`):

```sh
vault kv patch kv/main/renovate-operator \
  RENOVATE_FORGEJO_TOKEN=<forgejo-token> \
  RENOVATE_GITHUB_COM_TOKEN=<github-token>

kubectl -n renovate annotate externalsecret renovate-forgejo force-sync=$(date +%s) --overwrite
```

`SECRET_FORGEJO_HOSTNAME` is substituted from `ns-renovate-secret`
(`kubernetes/vars/main/namespaces/renovate`).

## Webhook (not enabled)

The operator can run Renovate for a single repository right away when Forgejo sends a
webhook, instead of waiting for the next hourly run. That helps with ticking checkboxes in
the Dependency Dashboard or in a PR ("rebase/retry"), and after merging a Renovate PR.
To enable it: set `webhook.enabled` in the job, make the operator's webhook endpoint
reachable from Forgejo, and add its host to `webhook.ALLOWED_HOST_LIST` in the Forgejo
config. By default Forgejo only sends webhooks to external hosts.
