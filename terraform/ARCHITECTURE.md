# Terraform Architectural Notes

These notes capture the current architectural direction for OpenTofu in this repository.

## State backend

Production state should use an S3-compatible backend.

Current preferred target:

- Garage as the S3-compatible object storage backend

Why:

- it already exists in the platform
- it avoids long-term reliance on local state
- it fits the repository goal of shared, durable infrastructure state

Recommended usage:

- local state is acceptable for short-lived experiments
- Garage-backed remote state should be used before managing real or shared infrastructure
- state should be separated at least by environment such as `main`, `test`, and `registry`

Possible later split:

- separate state per domain such as `dns`, `proxmox`, or `netbox` if the stacks become too large or require different access boundaries

## Workstation setup

Operators should be able to run OpenTofu locally with as little manual secret handling as possible.

Recommended workstation baseline:

- `tofu` installed locally
- `vault` CLI installed locally
- access to the local Vault config in `.secrets/vault.yaml`
- `task vault:ensure` working before any `tofu init`, `tofu plan`, or `tofu apply`

Recommended local workflow:

1. ensure Vault login is valid
2. read backend and provider credentials from Vault
3. export them as environment variables
4. run `tofu init`, `tofu plan`, or `tofu apply`

The existing Vault task helpers in [`.taskfiles/Vault/Taskfile.yaml`](../.taskfiles/Vault/Taskfile.yaml) already provide the basic login and secret-read flow.

## S3 state backend preparation

Before production state is used, the Garage-backed S3 backend should be prepared explicitly.

Recommended preparation:

1. create a dedicated bucket for OpenTofu state
2. use a dedicated access key and secret key with limited permissions
3. enable the strongest practical durability and backup strategy for the state bucket
4. separate state object paths by environment such as `main`, `test`, and `registry`
5. add a locking strategy that fits the final backend setup

Example object layout:

- `opentofu/main/terraform.tfstate`
- `opentofu/test/terraform.tfstate`
- `opentofu/registry/terraform.tfstate`

The backend configuration should stay partial, with sensitive values supplied through environment variables rather than committed in configuration files.

Example backend shape:

```hcl
terraform {
  backend "s3" {
    bucket = "opentofu-state"
    key    = "main/terraform.tfstate"
    region = "garage"
  }
}
```

Garage-specific endpoint, path-style, and credential details should be supplied at init time or through environment variables, not hardcoded into committed files.

## Secrets and Vault

Vault can be the secret source for OpenTofu, including backend credentials.

Recommended baseline:

- provider credentials should preferably come from environment variables
- backend credentials can also come from Vault and be exported into the environment before `tofu init`
- secret values should not be committed in `tfvars`
- long-lived secrets should remain stored in Vault

Possible Vault patterns:

1. Operators authenticate to Vault locally and export backend and provider credentials into the OpenTofu runtime environment
2. Wrapper tasks or scripts read selected values from Vault and inject them as environment variables before `tofu init`, `tofu plan`, or `tofu apply`
3. OpenTofu uses Vault as the secret source, not as a place to persist state

Important caveat:

If OpenTofu reads a secret and uses it in a resource or output, that value can still end up in state. Vault protects secret retrieval, but it does not automatically prevent secret exposure inside the state file.

Because of that, the preferred rule should be:

- use Vault to source credentials for providers and external APIs
- use Vault to source S3 backend credentials for Garage
- avoid pushing secret-heavy application data through OpenTofu unless it is truly infrastructure-level data
- treat remote state as sensitive even when Vault is used

### Example: backend credentials from Vault

One clean pattern is:

1. keep Garage S3 credentials in Vault
2. export them into the shell before `tofu init`
3. keep the backend block itself free of committed secrets

Example secret shape in Vault:

- path: `Infrastructure/opentofu-state`
- fields:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_S3_ENDPOINT`

Example local shell flow:

```bash
task vault:ensure

export AWS_ACCESS_KEY_ID="$(vault kv get -mount=Infrastructure -field=AWS_ACCESS_KEY_ID opentofu-state)"
export AWS_SECRET_ACCESS_KEY="$(vault kv get -mount=Infrastructure -field=AWS_SECRET_ACCESS_KEY opentofu-state)"
export AWS_S3_ENDPOINT="$(vault kv get -mount=Infrastructure -field=AWS_S3_ENDPOINT opentofu-state)"

tofu init
```

If Garage needs path-style access or other backend-specific flags, keep those in backend config or a non-secret backend config file, while credentials still come from Vault.

### Example: provider credentials from Vault

The same approach works for providers such as Proxmox or Cloudflare.

Example local shell flow:

```bash
task vault:ensure

export PM_API_URL="$(vault kv get -mount=Infrastructure -field=PM_API_URL proxmox-api)"
export PM_API_TOKEN_ID="$(vault kv get -mount=Infrastructure -field=PM_API_TOKEN_ID proxmox-api)"
export PM_API_TOKEN_SECRET="$(vault kv get -mount=Infrastructure -field=PM_API_TOKEN_SECRET proxmox-api)"
export CLOUDFLARE_API_TOKEN="$(vault kv get -mount=Infrastructure -field=CLOUDFLARE_API_TOKEN cloudflare-dns)"

tofu plan
```

### Example: Vault values used inside OpenTofu

OpenTofu can also consume Vault-sourced values as inputs, but this should be limited to true infrastructure needs because those values may still appear in state.

Safer pattern:

- fetch credentials from Vault
- export them into the environment
- let providers consume them directly

Higher-risk pattern:

- read secrets from Vault
- pass them into resources as arguments
- store resulting values in state

So the preferred rule remains:

- Vault is the source of truth for credentials
- environment variables are the preferred handoff into OpenTofu
- state must still be treated as sensitive

## Ownership boundaries

The intended split remains:

- `terraform/`: external infrastructure provisioning
- `talos/`: Talos and node configuration
- `kubernetes/`: in-cluster workloads and platform services

OpenTofu should provision infrastructure such as DNS, Proxmox resources, and possibly NetBox documentation. It should not replace Flux or the Talos bootstrap flow.
