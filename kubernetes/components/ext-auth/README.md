# Authentik External Auth

- Create Proxy Provider in Authentik
- Create `ReferenceGrant` in `security/authentik/references` per namespace


TODO: change to new envoy version (rederect location issue)

Issue: https://github.com/envoyproxy/gateway/issues/8202

SecurityPolicy extAuth redirect (location) issue with version 1.7

Envoy Gateway v1.7.0 (which bundles Envoy Proxy v1.37.0) has a known regression that breaks redirect-based extAuth flows in SecurityPolicy: the Location header is stripped from denied responses, so browsers see a 302 with HTML in the body but no redirect target and just render the page instead of redirecting. [ext-auth 302 issue; ext_authz regression]
