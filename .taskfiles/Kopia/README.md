# Kopia Tasks

Task helpers for connecting a local Kopia client, listing repository resources, and managing server users.

## Configuration

Defaults are read from `.secrets/kopia.yaml`:

```yaml
kopia:
  address: https://kopia.example.com
  username: user
  password: change-me
  hostname: ""
```

`address`, `username`, and `hostname` can be overridden as task arguments. The password is exported as `KOPIA_PASSWORD`.

## Login

```bash
task kopia:login
task kopia:login address=https://kopia.example.com username=user hostname=workstation
task kopia:logout
task kopia:status
```

## Lists

```bash
task kopia:snapshot:list
task kopia:policy:list
task kopia:user:list cluster=main
```

## User Management

User management runs the Kopia CLI inside `deployment/kopia` in the `storage` namespace. Override these defaults with `ns` and `target`.

```bash
task kopia:user:info username=user cluster=main
task kopia:user:add username=user password=secret cluster=main
task kopia:user:set-password username=user password=new-secret cluster=main
task kopia:user:delete username=user cluster=main
```

`name` can be used instead of `username`.
