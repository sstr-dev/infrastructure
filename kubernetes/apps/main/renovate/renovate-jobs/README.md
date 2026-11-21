# Renovate jobs

`RenovateJob` resources for the [renovate-operator](https://github.com/mogenius/renovate-operator).

| Job                        | Provider | Schedule | Notes |
|----------------------------|----------|----------|-------|
| [forgejo](./forgejo.yaml)  | Forgejo  | hourly   | Autodiscovers `sstr-dev/*` as bot user `renovate`. |

## Forgejo setup

Renovate runs as the dedicated bot user `renovate` (not `lab-assistant`): Renovate decides
whether it may rebase/force-push a branch by the commit author, so a shared account would
let it overwrite commits other tools pushed to `renovate/*` branches. It also keeps the
token limited to the repositories Renovate maintains.

Internal sign-in is disabled on Forgejo, so user and token are created with the Forgejo CLI
inside the pod:

```sh
kubectl -n dev exec -it deploy/forgejo -c forgejo -- forgejo admin user create \
  --username renovate --email bot-user+renovate@sstr.dev \
  --random-password --must-change-password=false

kubectl -n dev exec -it deploy/forgejo -c forgejo -- forgejo admin user generate-access-token \
  --username renovate \
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

Repository access: autodiscover only finds repositories `renovate` can write to.
Give the bot **Write** permission on Code, Issues and Pull Requests, either through an
org team (`sstr-dev` → Teams → `bots`, add `renovate` as member) or as a collaborator per repository.

Repositories without a `renovate.json` get an onboarding PR first. It proposes
`extends: ["local>sstr-dev/renovate-config"]` (`RENOVATE_ONBOARDING_CONFIG` in the job), so
the shared preset repository `sstr-dev/renovate-config` must exist on Forgejo with a
`default.json` (e.g. `{"extends": ["config:recommended"]}`) and be part of the `bots` team.
`local>` resolves against this Forgejo instance; do not use `gitea>`/`forgejo>`.

Restrict the account (Site Administration → User Accounts → `renovate` → Edit):
**Restricted** on, **May create organizations** off, **Max repository creation** `0`.
Do not set *Prohibit login*, it also blocks the API token.

Disable email notifications: the bot cannot sign in (internal sign-in is disabled) and
admins cannot change another user's notification setting, so set it in the database
(same as Settings → Notifications → Disabled):

```sh
# primary instance: kubectl -n database get cluster postgres
# database name: Vault key FORGEJO_POSTGRES_DB
kubectl -n database exec -it postgres-6 -c postgres -- psql -U postgres -d <forgejo-db> -c \
  "UPDATE \"user\" SET email_notifications_preference = 'disabled' WHERE lower_name = 'renovate';"
```

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
