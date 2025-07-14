# 🗂️ Namespace: `security`

This namespace contains authentication and secret management components that integrate Kubernetes with external identity and credential sources.

---

## 📦 Included Components

| Application                                 | Description                                        | Links                                                                                                 |
|---------------------------------------------|----------------------------------------------------|-------------------------------------------------------------------------------------------------------|
| [**external-secrets**](./external-secrets/) | Sync secrets from external providers to Kubernetes | [Website](https://external-secrets.io) [GitHub](https://github.com/external-secrets/external-secrets) |
| [**lldap**](./lldap/)                       | Lightweight and simple LDAP server                 | [GitHub](https://github.com/lldap/lldap) [Docs](https://lldap.dev)                                    |

---

## 📎 Notes

- `external-secrets` supports providers like Vault, AWS Secrets Manager, Azure Key Vault, etc.
- `lldap` can be used as the central directory service (auth source) for tools like Authelia, Dex, or GitLab.
