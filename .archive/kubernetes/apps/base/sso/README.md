# 🗂️ Namespace: `sso`

This namespace includes identity and access management platforms that act as central authentication providers for services within and outside the Kubernetes cluster.

---

## 📦 Included Components

| Application                   | Description                                           | Links                                                                                |
|-------------------------------|-------------------------------------------------------|--------------------------------------------------------------------------------------|
| [**authentik**](./authentik/) | Modern identity provider with flexible policy engine  | [Website](https://goauthentik.io) [GitHub](https://github.com/goauthentik/authentik) |
| [**keycloak**](./keycloak/)   | Open-source Identity and Access Management by Red Hat | [Website](https://www.keycloak.org) [GitHub](https://github.com/keycloak/keycloak)   |

---

## 📎 Notes

- Both providers support OAuth2, OIDC, and SAML integrations.
- You can configure them as login sources for services like Grafana, Mealie, or Paperless.
- Consider secure external exposure via `network` namespace (e.g., `envoy`, `nginx`, `cloudflare-tunnel`).
