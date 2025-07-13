# Authentik

Authentik is an identity provider.
It can be used to do unified auth across many applications.
It can also be used as a proxy, adding auth to simple applications that don't have it on its own.

References:
- https://goauthentik.io/#comparison

# Generate config

AUTHENTIK_SECRET_KEY

```bash
openssl rand -base64 60 | tr -d '\n'
```

PG_PASS

```bash
openssl rand -base64 36 | tr -d '\n'
```

# InsufficientPrivilege: permission denied for schema public

Solution: ALTER DATABASE authentik OWNER TO authentik;

