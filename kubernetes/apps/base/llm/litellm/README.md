# LiteLLM

OpenAI-compatible gateway in front of all local models and MCP servers, managed by
[litellm-operator](https://github.com/home-operations/litellm-operator) CRDs.

```
clients ──► LiteLLM (keys, teams, budgets, logs, cache) ──┬─► Ollama Jetson vision-01   (qwen3-4b, minicpm-v)
                                                          ├─► Ollama workstation        (ws-*)
                                                          └─► MCP servers               (searxng)
```

| Path | Content |
|------|---------|
| `operator/` | litellm-operator HelmRelease |
| `app/proxy.yaml` | `LiteLLMProxy` (config, router, fallbacks, probes, route) |
| `app/models/<backend>/` | one `LiteLLMModel` per file |
| `app/teams/` | access control upper bound per consumer group |
| `app/keys/` | one `LiteLLMVirtualKey` per consumer (+ `PushSecret` to Vault for dev keys) |
| `app/mcps/` | `LiteLLMMCPServer` (HTTP servers via `workload:`, stdio-only via ToolHive + `url:`) |
| `app/networkpolicies/` | LiteLLM is the only way in; MCP pods only reachable from LiteLLM |

## Access control

| Team | Consumers | Models | MCP | Limits |
|------|-----------|--------|-----|--------|
| `home` | open-webui, paperless-gpt, paperless-ai (later HA, n8n) | Jetson only | searxng | 60 rpm |
| `dev` | opencode, continue, lmstudio | workstation `ws-*` + `qwen3-4b` fallback | searxng | 20 USD / 30d (cloud) |

Keys can only narrow their team. `lmstudio` has `no-default-models` (MCP only).

Ollama itself has no auth: restrict port 11434 on both Ollama hosts to the
cluster nodes (`10.0.60.201-206`) and localhost, so LiteLLM is the only entry.

## Prerequisites

- Vault `kv/main/litellm`: `LITELLM_MASTER_KEY`, `LITELLM_SALT_KEY`, `LITELLM_POSTGRES_*`,
  `OLLAMA_WORKSTATION_HOST` (IP/hostname of the workstation Ollama)

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
