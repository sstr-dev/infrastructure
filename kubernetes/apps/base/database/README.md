# 🗂️ Namespace: `database`

This namespace contains a curated set of tools and operators for managing databases and data services in the Kubernetes cluster. It supports both development and production-grade database engines, GUI access, and caching layers.

---

## 📦 Included Components

### 🐘 Crunchy Postgres
- **Purpose:** Production-ready PostgreSQL operator from Crunchy Data.
- **Features:** Backup/restore, replication, HA, and monitoring.
- **Use case:** Stateful workloads requiring relational databases with enterprise support.
- **Docs:** https://access.crunchydata.com/documentation/postgres-operator/

---

### 📊 dbgate
- **Purpose:** Web-based database management GUI.
- **Use case:** Lightweight database browser and query runner, useful for development and testing.
- **Supports:** PostgreSQL, MySQL, MongoDB, and others.
- **Docs:** https://github.com/dbgate/dbgate

---

### 🐉 Dragonfly
- **Purpose:** High-performance Redis-compatible in-memory data store.
- **Use case:** Acts as a drop-in replacement for Redis in caching, pub/sub, and session storage.
- **Docs:** https://www.dragonflydb.io/

---

### 🧱 KubeBlocks
- **Purpose:** Declarative database lifecycle manager for Kubernetes.
- **Supports:** MySQL, PostgreSQL, MongoDB, Redis, Kafka, etc.
- **Use case:** Operator to simplify deployment and management of multiple database engines using CRDs and addons.
- **Docs:** https://kubeblocks.io/docs/

---

## Backups

### Used s3 buckets

- **postgresql-backup:** Backups for postgresql.
- **mysql-backup:** Backups for mysql/mariadb.
- **mongodb-backup:** Backups for mongodb.

### S3 Configuration for backups (single)

1. Create the Minio CLI configuration file (`~/.mc/config.json`)

    ```sh
    mc alias set minio https://s3.<domain> <access-key> <secret-key>
    ```

2. Create the postgres user and password

    ```sh
    mc admin user add minio postgresql <super-secret-password>
    ```

#### single (not kubeblocks)

3. Create the postgres bucket

    ```sh
    mc mb minio/postgresql
    ```

4. Create `/tmp/postgresql-user-policy.json`

    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                    "s3:ListBucket",
                    "s3:PutObject",
                    "s3:GetObject",
                    "s3:DeleteObject"
                ],
                "Effect": "Allow",
                "Resource": ["arn:aws:s3:::postgresql/*", "arn:aws:s3:::postgresql", "arn:aws:s3:::crunchy-pgo/*", "arn:aws:s3:::crunchy-pgo", "arn:aws:s3:::crunchy-postgres/*", "arn:aws:s3:::crunchy-postgre"],
                "Sid": ""
            }
        ]
    }
    ```

5. Apply the bucket policies

    ```sh
    mc admin policy add minio postgresql-private /tmp/postgresql-user-policy.json
    ```

6. Associate private policy with the user

    ```sh
    mc admin policy attach minio postgresql-private --user=postgresql
    ```

#### kubeblocks

3. Create the postgres bucket

    ```sh
    mc mb minio/kb-backup
    ```

4. Create `/tmp/kb-backup-user-policy.json`

    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:GetBucketLocation",
                    "s3:ListBucket"
                ],
                "Resource": [
                    "arn:aws:s3:::kb-backup"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "s3:*"
                ],
                "Resource": [
                    "arn:aws:s3:::kb-backup/*"
                ]
            }
        ]
    }
    ```

5. Apply the bucket policies

    ```sh
    mc admin policy add minio kb-backup-private /tmp/kb-backup-user-policy.json
    ```

6. Associate private policy with the user

    ```sh
    mc admin policy attach minio kb-backup-private --user=kb-backup
    ```
