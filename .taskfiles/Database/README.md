# Database Taskfile

This Taskfile provides operational helpers for the database workloads in the cluster.

Current scope:

- show a cross-database overview
- inspect CloudNativePG clusters and backups
- run one-off CNPG backups
- open `psql`, list databases, dump, restore, and create databases for CNPG
- inspect MariaDB operator resources and backups
- dump MariaDB operator-managed databases
- exec into, inspect, dump, and restore a MariaDB single-server pod
- inspect MongoDBCommunity resources

The root Taskfile exposes these tasks through:

- `database:*`
- alias: `db:*`

## Requirements

Most tasks require:

- `kubectl`
- a valid kubeconfig context

Some tasks also require:

- `task` for nested task execution in `overview`
- local filesystem access for dump and restore files

## Common Arguments

Most tasks use:

- `cluster=<context>`: required Kubernetes context
- `ns=<namespace>`: defaults to `database`

Examples:

```bash
task database:overview cluster=main
task db:overview cluster=main
task db:cnpg:clusters cluster=main ns=database
```

## Tasks

### Overview

- `task db:overview cluster=<cluster>`

This prints a compact overview of the database resources available in the selected cluster and namespace.

## CloudNativePG

Available tasks:

- `task db:cnpg:clusters cluster=<cluster>`
- `task db:cnpg:backups cluster=<cluster>`
- `task db:cnpg:backup cluster=<cluster> [dbcluster=<name>]`
- `task db:cnpg:psql cluster=<cluster> [dbcluster=<name>]`
- `task db:cnpg:databases cluster=<cluster> [dbcluster=<name>]`
- `task db:cnpg:dump cluster=<cluster> database=<db>`
- `task db:cnpg:restore cluster=<cluster> database=<db> file=<path>`
- `task db:cnpg:create-db cluster=<cluster> user=<user> database=<db>`

Defaults:

- `ns=database`
- `dbcluster=postgres`
- `database=postgres`
- `user=postgres`

### CNPG examples

List CNPG clusters:

```bash
task db:cnpg:clusters cluster=main
```

Trigger a one-off backup:

```bash
task db:cnpg:backup cluster=main dbcluster=postgres
```

Open a `psql` session:

```bash
task db:cnpg:psql cluster=main dbcluster=postgres database=app user=postgres
```

List databases:

```bash
task db:cnpg:databases cluster=main dbcluster=postgres
```

Create a local dump in custom format:

```bash
task db:cnpg:dump \
  cluster=main \
  dbcluster=postgres \
  database=app \
  type=custom
```

Create a local plain SQL dump:

```bash
task db:cnpg:dump \
  cluster=casa-rke2 \
  dbcluster=postgres-cluster \
  database=n8n \
  type=plain
```

Restore a custom dump:

```bash
task db:cnpg:restore \
  cluster=main \
  dbcluster=postgres \
  database=app \
  file=.local/cnpg/dump/postgres-app-custom.dump \
  type=custom
```

Restore a plain SQL dump:

```bash
task db:cnpg:restore \
  cluster=main \
  dbcluster=postgres \
  database=app \
  file=.local/cnpg/dump/postgres-app-plain.sql \
  type=plain
```

Restore a custom dump and clean existing objects first:

```bash
task db:cnpg:restore \
  cluster=main \
  dbcluster=postgres \
  database=app \
  file=.local/cnpg/dump/postgres-app-custom.dump \
  type=custom \
  clean=true
```

Create or update a role and database:

```bash
task db:cnpg:create-db \
  cluster=main \
  dbcluster=postgres \
  user=app \
  database=app
```

Notes:

- `cnpg:create-db` prompts for the application password interactively.
- `cnpg:dump` supports `type=custom` and `type=plain`.
- `cnpg:restore` supports `type=custom|plain` and `clean=true|false`.

## MariaDB Operator

These tasks target `mariadb.k8s.mariadb.com` resources.

Available tasks:

- `task db:mariadb:clusters cluster=<cluster>`
- `task db:mariadb:dump cluster=<cluster> database=<db>`
- `task db:mariadb:backup cluster=<cluster> [name=mariadb-backup]`

Defaults:

- `ns=database`
- `name=mariadb`
- `secret=mariadb-secret`
- `passwordKey=rootPassword`

### MariaDB operator examples

List MariaDB resources:

```bash
task db:mariadb:clusters cluster=main
```

Dump a MariaDB operator-managed database:

```bash
task db:mariadb:dump \
  cluster=main \
  name=mariadb \
  database=app
```

Dump to a custom file:

```bash
task db:mariadb:dump \
  cluster=main \
  name=mariadb \
  database=app \
  file=.local/mariadb/dump/mariadb-app.sql
```

Show the backup resource:

```bash
task db:mariadb:backup cluster=main name=mariadb-backup
```

Notes:

- `mariadb:dump` reads the root password from the configured Kubernetes secret.
- The task expects a pod name starting with `<name>-`.

## MariaDB Single Server

These tasks target a plain MariaDB pod or Helm release, not the operator-managed CRs.

Available tasks:

- `task db:mariadb-server:exec cluster=<cluster>`
- `task db:mariadb-server:databases cluster=<cluster>`
- `task db:mariadb-server:dump cluster=<cluster> database=<db>`
- `task db:mariadb-server:restore cluster=<cluster> database=<db> file=<path>`

Defaults:

- `ns=database`
- `release=mariadb`

### MariaDB single-server examples

Open an interactive shell:

```bash
task db:mariadb-server:exec cluster=main
```

Run a custom command:

```bash
task db:mariadb-server:exec \
  cluster=main \
  cmd='mariadb -uroot -e "SHOW DATABASES;"'
```

List databases:

```bash
task db:mariadb-server:databases cluster=main
```

Dump a database:

```bash
task db:mariadb-server:dump \
  cluster=main \
  database=nextcloud
```

Restore a dump:

```bash
task db:mariadb-server:restore \
  cluster=main \
  database=nextcloud \
  file=.local/mariadb/dump/mariadb-nextcloud.sql
```

Notes:

- These tasks find the target pod by prefix matching on `release`.
- Dumps are written locally under `.local/mariadb/dump` by default.

## MongoDBCommunity

Available tasks:

- `task db:mongo:clusters cluster=<cluster>`

Example:

```bash
task db:mongo:clusters cluster=main
```

Note:

- MongoDB support is currently inspection-focused only.

## Output Locations

Default dump locations:

- CNPG: `.local/cnpg/dump`
- MariaDB: `.local/mariadb/dump`

You can override these with `folder=` or `file=` where supported.

## Safety Notes

- Restore tasks write directly into live databases. Double-check `cluster`, `dbcluster`, `database`, and `file` before running them.
- `cnpg:create-db` updates an existing role password if the role already exists.
- `cnpg:restore clean=true` can drop existing objects before restore.
- `mariadb-server:exec` opens an interactive command session in the target pod.
