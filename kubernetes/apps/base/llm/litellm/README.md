# LiteLLM

OpenAI-compatible gateway in front of all local models and MCP servers, managed by
[litellm-operator](https://github.com/home-operations/litellm-operator) CRDs.

```
clients ──► LiteLLM (keys, teams, budgets, logs, cache) ──┬─► Ollama Jetson vision-01   (local-chat, local-fast, minicpm-v, local-embed-vision)
                                                          ├─► Ollama hv-geekom-01       (local-embed, local-embed-large)
                                                          ├─► Ollama workstation        (ws-*)
                                                          └─► MCP servers               (searxng, home_assistant, kubernetes, flux, unifi_network)
```

| Path | Content |
|------|---------|
| `operator/` | litellm-operator HelmRelease |
| `app/proxy.yaml` | `LiteLLMProxy` (config, router, fallbacks, probes, route) |
| `app/models/<backend>/` | one `LiteLLMModel` per file |
| `app/teams/` | access control upper bound per consumer group |
| `app/keys/` | one `LiteLLMVirtualKey` per consumer (+ `PushSecret` to Vault for dev keys) |
| `app/mcps/` | `LiteLLMMCPServer` (HTTP servers via `workload:`, stdio-only via ToolHive + `url:`) |
| `app/networkpolicies/` | LiteLLM is the only way in; MCP pods only reachable from LiteLLM. **Disabled**, see `app/kustomization.yaml` (Cilium DSR + hostNamespaceOnly socket-LB) |

## Access control

| Team | Consumers | Models | MCP | Limits |
|------|-----------|--------|-----|--------|
| `home` | open-webui, paperless-gpt, paperless-ai (later HA, n8n) | always-on hosts only (`local-*`, `minicpm-v`) | searxng (+ home_assistant) | 60 rpm |
| `dev` | continue | workstation `ws-*` + `local-chat` / `local-embed` fallback | searxng, kubesearch | 20 USD / 30d (cloud) |
| `ops` | opencode, lmstudio | tool-calling `ws-qwen3.8-27b`, `ws-qwen3.5-9b` + `local-chat` fallback | searxng, kubesearch, kubectl, flux (+ unifi_network, home_assistant) | 20 USD / 30d (cloud) |

MCP servers in parentheses are prepared but commented out until enabled in `app/mcps/kustomization.yaml`.
Fallback targets (`proxy.yaml` `routerSettings.fallbacks`) must be in the caller's team.

A team is the ceiling. Keys narrow **models** via `models` and **MCP tools** via
`mcpToolsets` (see [Toolsets](#toolsets)); a key without toolsets sees every MCP
server of its team. `lmstudio` has `no-default-models` (MCP only).

### MCP servers

Every server pins `params.server_id` to its alias. Without the pin LiteLLM derives
the id from a hash of name/url/transport/alias, and any edit silently orphans the
toolsets that reference it.

| Alias | Server | Scope |
|-------|--------|-------|
| `searxng` | mcp-searxng | web search |
| `kubesearch` | kubesearch-mcp | search over public home-ops HelmReleases (kubesearch.dev), no cluster access |
| `kubectl` | kubectl-mcp-server | `--read-only`, toolsets `core,diagnostics,crds,certs,cilium,gitops`; ClusterRoles `kubectl-mcp-readonly*` (no Secrets) |
| `flux` | flux-operator-mcp | **read-write** |
| `home_assistant` | ha-mcp → external HA | `allowed_tools` whitelist: read state, `ha_call_service`/`ha_bulk_control`, todo, calendar. No automation/backup/restart tools |
| `unifi_network` | unifi-network-mcp | no `UNIFI_POLICY_*` gates (mutations denied), dedicated read-only local account |

### Toolsets

A toolset is a named list of `server_id` + tool pairs, stored in the LiteLLM DB
(random UUID, no CRD). On a key, `mcpToolsets` restricts it to exactly those tools,
capped by the team. Toolsets are created in the UI; only their IDs live in git.

1. **Create.** `https://litellm.<domain>/ui` → **MCP Servers** → **Toolsets** tab →
   **New Toolset**: name, description, pick the tools → **Create Toolset**.
   Suggested set:

   | Toolset | Tools | For | ID |
   |---------|-------|-----|----|
   | `research` | searxng: all · kubesearch: all | dev/continue, every agent | d5aaa841-2445-4855-8b20-a84544f7556a |
   | `cluster-read` | kubectl: all (server is `--read-only`) · flux: `get_flux_instance`, `get_kubernetes_resources`, `trace_kubernetes_resource`, `get_kubernetes_logs`, `get_kubernetes_events`, `get_kubernetes_metrics`, `get_kubernetes_api_versions`, `diff_kubernetes_manifest`, `search_flux_docs`, `read_flux_doc` | ops agents | ee1c96f1-d1ef-4c0a-810b-f63d0bf7fe7a |
   | `flux-operate` | flux: `reconcile_flux_resource`, `suspend_flux_reconciliation`, `resume_flux_reconciliation` | opencode | 1e46e758-3d43-4294-b9af-620632b5f71a |
   | `flux-write` | flux: `apply_kubernetes_manifest`, `patch_kubernetes_resource`, `delete_kubernetes_resource` | only if really needed (cluster-admin, see above) | f11abf7a-9418-4003-82e1-265c53ecc667 |

2. **Copy the IDs**: Toolsets table in the UI, or `GET /v1/mcp/toolset` as above.
3. **Assign** in `app/keys/<app>.yaml` and commit:
   ```yaml
   spec:
     mcpToolsets:
       - <research-uuid>
       - <cluster-read-uuid>
   ```

   Current assignment:

   | Key | Toolsets |
   |-----|----------|
   | `continue` | research |
   | `opencode` | research, cluster-read, flux-operate |
   | `lmstudio` | research, cluster-read |
   | home keys | none (team `home` only has searxng) |

   `flux-write` is assigned to no key. Add it to `opencode` only when an agent
   really has to apply/patch/delete.
4. **Clients**: keep `https://litellm.<domain>/mcp/` (shows the union of the key's
   toolsets), or point at one toolset: `https://litellm.<domain>/toolset/<name>/mcp`
   (403 unless the key holds that toolset).

Editing a toolset (tools, name) keeps its UUID. **Deleting and recreating it changes
the UUID**, and a key whose declared toolset no longer resolves loses all MCP access
until the ID in git is updated.

## Prerequisites

- Vault `kv/main/litellm`: `LITELLM_MASTER_KEY`, `LITELLM_SALT_KEY`, `LITELLM_POSTGRES_*`,
  `LITELLM_OLLAMA_WORKSTATION_HOST` (IP/hostname of the workstation Ollama),
  `LITELLM_OIDC_CLIENT_ID`, `LITELLM_OIDC_CLIENT_SECRET` (authentik SSO),
  `LITELLM_HASS_URL` (`https://<ha-host>`), `LITELLM_HASS_TOKEN` (long-lived token of a
  dedicated **non-admin** HA user)
  `LITELLM_UNIFI_NETWORK_HOST` (bare IP/hostname), `LITELLM_UNIFI_NETWORK_USERNAME`,
  `LITELLM_UNIFI_NETWORK_PASSWORD` (dedicated local read-only UniFi account)

## SSO (authentik)

Admin UI `https://litellm.<domain>/ui` logs in via authentik (generic OIDC):

- authentik: OAuth2/OpenID provider, confidential client,
  redirect URI `https://litellm.<domain>/sso/callback`, scopes `openid email profile`
- roles from the `groups` claim: `homelab-admins` → `proxy_admin`,
  `litellm-users` → `internal_user`, everyone else → `internal_user_viewer`
- free tier allows SSO for up to 5 users; the master key login keeps working

## Clients (workstation)

Keys are pushed to Vault:

```fish
set -x LITELLM_API_KEY (vault kv get -field=key kv/shared/main/litellm/opencode)
```

Base URL: `https://litellm.<domain>/v1`, MCP gateway: `https://litellm.<domain>/mcp/`

### OpenCode (`~/.config/opencode/opencode.json`, key `opencode`)

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "litellm": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "LiteLLM",
      "options": {
        "baseURL": "https://litellm.<domain>/v1",
        "apiKey": "{env:LITELLM_API_KEY}"
      },
      "models": {
        "ws-qwen3.8-27b": { "name": "Qwen3.8 27B (workstation)" },
        "ws-qwen3.5-9b": { "name": "Qwen3.5 9B (workstation)" }
      }
    }
  },
  "model": "litellm/ws-qwen3.5-9b",
  "mcp": {
    "litellm": {
      "type": "remote",
      "url": "https://litellm.<domain>/mcp/",
      "headers": { "x-litellm-api-key": "Bearer {env:LITELLM_API_KEY}" }
    }
  }
}
```

### Continue (`~/.continue/config.yaml`, key `continue`)

Autocomplete stays on the local Ollama (latency); everything else via LiteLLM.

```yaml
name: home
version: 1.0.0
schema: v1
models:
  - name: Qwen2.5 Coder 7B
    provider: openai
    model: ws-qwen2.5-coder-7b
    apiBase: https://litellm.<domain>/v1
    apiKey: ${{ secrets.LITELLM_API_KEY }}
    roles: [chat, edit, apply]
  - name: Qwen3.5 9B
    provider: openai
    model: ws-qwen3.5-9b
    apiBase: https://litellm.<domain>/v1
    apiKey: ${{ secrets.LITELLM_API_KEY }}
    roles: [chat]
  - name: Embeddings
    provider: openai
    model: ws-nomic-embed-text
    apiBase: https://litellm.<domain>/v1
    apiKey: ${{ secrets.LITELLM_API_KEY }}
    roles: [embed]
  - name: Autocomplete
    provider: ollama
    model: qwen2.5-coder:1.5b
    apiBase: http://localhost:11434
    roles: [autocomplete]
mcpServers:
  - name: litellm
    type: streamable-http
    url: https://litellm.<domain>/mcp/
    requestOptions:
      headers:
        x-litellm-api-key: Bearer ${{ secrets.LITELLM_API_KEY }}
```

### LM Studio (`mcp.json`, key `lmstudio`)

LM Studio runs its own models; LiteLLM only provides the MCP tools.

```json
{
  "mcpServers": {
    "litellm": {
      "url": "https://litellm.<domain>/mcp/",
      "headers": { "x-litellm-api-key": "Bearer sk-..." }
    }
  }
}
```
