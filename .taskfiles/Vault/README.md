# Vault Taskfile

This Taskfile provides a small set of helpers for working with HashiCorp Vault from this repository.

Current scope:

- ensure a valid Vault login using local config
- read a KV secret from a configurable mount and path
- read the latest version of a KV secret with version metadata
- inject `vault://` references from standard input

The root Taskfile exposes these tasks through:

- `vault:*`

## Configuration

The Taskfile reads Vault connection settings from:

- `.secrets/vault.yaml`

Expected structure:

```yaml
vault:
  address: https://vault.example.com
  token: your-vault-token
```

These values are exported as environment variables for the Vault CLI:

- `VAULT_ADDR`
- `VAULT_TOKEN`

## Tasks

Available tasks:

- `task vault:vault`
- `task vault:ensure`
- `task vault:read`
- `task vault:read-latest`
- `task vault:inject`

## Authentication

Two tasks currently validate login:

- `vault:vault`
- `vault:ensure`

Both check whether the current token is valid with `vault token lookup`.
If the token is not valid, they attempt a non-interactive login using the configured token from `.secrets/vault.yaml`.

Examples:

```bash
task vault:vault
```

```bash
task vault:ensure
```

Notes:

- `vault:ensure` is quieter and is intended for use as a dependency in other tasks.
- If `.secrets/vault.yaml` is missing, these tasks fail immediately.

## Read Secret

`vault:read` is now generic and reads any KV secret you provide.

Arguments:

- `mount=<mount>`: required
- `path=<path>`: required
- `name=<path>`: optional alias for `path`

Example:

```bash
task vault:read mount=Kubernetes path=talos-main
```

Equivalent alias form:

```bash
task vault:read mount=Kubernetes name=talos-main
```

This runs:

```bash
vault kv get -mount=Kubernetes talos-main
```

## Read Latest Version

`vault:read-latest` reads metadata first, extracts the current KV v2 version with `jq`, and then fetches that exact version.

Arguments:

- `mount=<mount>`: required
- `path=<path>`: required
- `name=<path>`: optional alias for `path`

Example:

```bash
task vault:read-latest mount=Kubernetes path=talos-main
```

This is useful when you want proof of the currently active secret version instead of relying on the implicit latest lookup.

Requirements:

- `jq`

## Inject `vault://` References

`vault:inject` reads from standard input and replaces `vault://` references using the helper script:

- [vault-inject.py](/home/sst/sstr-dev/infrastructure/scripts/vault-inject.py)

Example:

```bash
cat some-file.yaml | task vault:inject
```

You can also use it in pipelines where manifest templates contain `vault://` placeholders.

## Requirements

Most tasks require:

- `vault` CLI
- access to `.secrets/vault.yaml`

Some tasks also require:

- `jq` for `vault:read-latest`

## Notes

- This Taskfile is still intentionally minimal.
