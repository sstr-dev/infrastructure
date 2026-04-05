# Garage Taskfile

This Taskfile provides a small set of operational commands for managing Garage S3 buckets through the S3 API.

Scope:

- show Garage cluster status
- list, inspect, create, and delete buckets
- list, inspect, and create access keys
- print key credentials
- grant and revoke bucket permissions
- bootstrap a bucket and access key together
- show the configured Garage endpoint
- read bucket CORS configuration
- apply bucket CORS configuration
- update bucket CORS configuration
- remove bucket CORS configuration

## Tasks

- `task garage:status`
- `task garage:bucket:list`
- `task garage:bucket:info bucket=<bucket>`
- `task garage:bucket:create bucket=<bucket>`
- `task garage:bucket:delete bucket=<bucket>`
- `task garage:key:list`
- `task garage:key:info key=<key>`
- `task garage:key:create key=<key>`
- `task garage:key:credentials key=<key>`
- `task garage:bucket:grant bucket=<bucket> key=<key>`
- `task garage:bucket:revoke bucket=<bucket> key=<key>`
- `task garage:bucket:setup bucket=<bucket>`
- `task garage:endpoint`
- `task garage:bucket:cors:get bucket=<bucket>`
- `task garage:bucket:cors:set bucket=<bucket> origin=<origin>`
- `task garage:bucket:cors:update bucket=<bucket> origin=<origin>`
- `task garage:bucket:cors:delete bucket=<bucket>`

Aliases are also available through `s3:*`, for example:

- `task s3:endpoint`
- `task s3:bucket:cors:set bucket=manyfold origin=https://manyfold.example.com`

## Configuration

The Taskfile reads default Garage connection settings from:

- `.secrets/garage.yaml`

Expected structure:

```yaml
garage:
  address: https://s3.example.com
  access_key: your-access-key
  secret_key: your-secret-key
```

These values are exposed inside the Taskfile as:

- `GARAGE_DEFAULT_ADDR`
- `GARAGE_DEFAULT_ACCESS_KEY`
- `GARAGE_DEFAULT_SECRET_KEY`

For Garage admin operations through `kubectl exec`, the Taskfile also defaults to:

- namespace: `storage`
- target: `deployment/garage`

These can be overridden per task with:

- `ns=<namespace>`
- `target=<kubectl-exec-target>`

## Resolution Order

For `endpoint`, `access_key`, and `secret_key`, the Taskfile resolves values in this order:

1. explicit task argument
2. AWS environment variables for credentials
3. Garage defaults from `.secrets/garage.yaml`

Credential mapping:

- `access_key` -> `AWS_ACCESS_KEY_ID` -> `GARAGE_DEFAULT_ACCESS_KEY`
- `secret_key` -> `AWS_SECRET_ACCESS_KEY` -> `GARAGE_DEFAULT_SECRET_KEY`
- `endpoint` -> `GARAGE_DEFAULT_ADDR`

## AWS CLI Fallback

The tasks prefer a local `aws` CLI when available.

If `aws` is not installed locally, they fall back to a temporary Kubernetes pod started with `kubectl run` using the `public.ecr.aws/aws-cli/aws-cli:2.17.57` image.

For the fallback path:

- `cluster` should be provided so `kubectl` knows which context to use
- `ns` defaults to `storage`

Example:

```bash
task garage:bucket:cors:get bucket=manyfold cluster=main
```

Note:

- `garage:bucket:cors:set` still requires local `jq` because the CORS payload is generated before the API call is executed.

## Garage Admin Access

Bucket, key, and grant management tasks use the Garage admin CLI.

They always run through `kubectl exec` against the configured Garage deployment.

Example:

```bash
task garage:bucket:list cluster=main
```

## Management Examples

Show Garage cluster status:

```bash
task garage:status cluster=main
```

List buckets:

```bash
task garage:bucket:list cluster=main
```

Create a bucket:

```bash
task garage:bucket:create bucket=manyfold cluster=main
```

Show bucket details:

```bash
task garage:bucket:info bucket=manyfold cluster=main
```

Create an access key:

```bash
task garage:key:create key=manyfold-app cluster=main
```

Create an access key and print credentials as environment variables:

```bash
task garage:key:create key=manyfold-app format=env cluster=main
```

Read existing key details:

```bash
task garage:key:info key=manyfold-app cluster=main
```

Print credentials for a key:

```bash
task garage:key:credentials key=manyfold-app format=env cluster=main
```

Grant full bucket access:

```bash
task garage:bucket:grant \
  bucket=manyfold \
  key=manyfold-app \
  permissions=read,write,owner \
  cluster=main
```

Grant read-only access:

```bash
task garage:bucket:grant \
  bucket=manyfold \
  key=manyfold-readonly \
  permissions=read \
  cluster=main
```

Revoke access again:

```bash
task garage:bucket:revoke \
  bucket=manyfold \
  key=manyfold-app \
  permissions=read,write,owner \
  cluster=main
```

Bootstrap a bucket, create a key, and grant access in one flow:

```bash
task garage:bucket:setup \
  bucket=manyfold \
  key=manyfold-app \
  permissions=read,write,owner \
  format=env \
  cluster=main
```

## Examples

Show the default endpoint:

```bash
task garage:endpoint
```

Read the current bucket CORS configuration:

```bash
task garage:bucket:cors:get bucket=manyfold
```

Apply a basic read-only browser CORS policy:

```bash
task garage:bucket:cors:set \
  bucket=manyfold \
  origin=https://manyfold.example.com
```

Apply a policy with multiple allowed origins:

```bash
task garage:bucket:cors:set \
  bucket=manyfold \
  origins=https://manyfold.example.com,https://preview.example.com
```

Apply a more complete CORS policy:

```bash
task garage:bucket:cors:set \
  bucket=manyfold \
  origins=https://manyfold.example.com,https://preview.example.com \
  methods=GET,HEAD,PUT \
  allowed_headers=* \
  expose_headers=ETag \
  max_age=3600
```

Update an existing CORS configuration explicitly:

```bash
task garage:bucket:cors:update \
  bucket=manyfold \
  origins=https://manyfold.example.com,https://preview.example.com \
  methods=GET,HEAD
```

Remove bucket CORS:

```bash
task garage:bucket:cors:delete bucket=manyfold
```

Use explicit credentials and endpoint overrides:

```bash
task garage:bucket:cors:get \
  bucket=manyfold \
  endpoint=http://garage.database.svc.cluster.local:3900 \
  access_key=your-access-key \
  secret_key=your-secret-key
```

Use the Kubernetes fallback explicitly by relying on defaults and passing only the cluster:

```bash
task garage:bucket:cors:set \
  bucket=manyfold \
  origins=https://manyfold.example.com,https://preview.example.com \
  cluster=main
```

## Notes

- `garage:key:create` prints credentials at creation time and supports `format=text|env|json`.
- `garage:key:credentials` attempts to print credentials for an existing key from `garage key info`.
- `garage:bucket:grant` and `garage:bucket:revoke` support `permissions=read,write,owner`.
- `garage:bucket:setup` is the quickest path for a new application bucket.
- The CORS commands use the S3 API via `aws s3api`.
- `bucket:cors:update` is an explicit alias for `bucket:cors:set`, which replaces the current CORS configuration on the bucket.
- You can pass either `origin=<single-origin>` or `origins=<origin1,origin2,...>`.
- The default AWS region is `us-east-1`.

