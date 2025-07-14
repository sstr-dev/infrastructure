# 🗂️ Namespace: `database`

This namespace contains a curated set of tools and operators for managing databases and data services in the Kubernetes cluster. It supports both development and production-grade database engines, GUI access, and caching layers.

---

## 📦 Included Components

| Application                                 | Description                             | Links                                                                                                                    |
|---------------------------------------------|-----------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| [**cnpg**](./cnpg/)                         | CloudNativePG – a PostgreSQL operator   | [Vendor](https://cloudnative-pg.io/)                                                                                     |
| [**crunchy-postgres**](./crunchy-postgres/) | PostgreSQL by CrunchyData (legacy/test) | [Vendor](https://www.crunchydata.com/developers) [Docs](https://access.crunchydata.com/documentation/postgres-operator/) |
| [**dbgate**](./dbgate/)                     | Web-based database client UI            | [Vendor](https://dbgate.org/) [GitHub](https://github.com/dbgate/dbgate)                                                 |
| [**dragonfly**](./dragonfly/)               | High-performance in-memory data store   | [Vendor](https://dragonflydb.io/)                                                                                        |
| [**influx**](./influx/)                     | Time-series database for metrics/logs   | [Vendor](https://www.influxdata.com/)                                                                                    |
| [**mariadb**](./mariadb/)                   | Lightweight MySQL-compatible database   | [Vendor](https://mariadb.org/)                                                                                           |
| [**mongo**](./mongo/)                       | Document-oriented NoSQL database        | [Vendor](https://www.mongodb.com/)                                                                                       |

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
