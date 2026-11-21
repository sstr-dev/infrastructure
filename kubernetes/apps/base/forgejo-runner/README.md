# Namespace: `forgejo-runner`

Isolated Forgejo Actions runner. Forgejo itself stays in `dev`.

| Application                         | Description                          | Links | Notes |
|-------------------------------------|--------------------------------------|-------|-------|
| [forgejo-runner](./forgejo-runner/) | Forgejo runner + runner-k8s-plugin   | [Runner](https://code.forgejo.org/forgejo/runner) [Plugin](https://git.erwanleboucher.dev/eleboucher/runner-k8s-plugin) | Every workflow job runs as its own Kubernetes Job in this namespace. |

- Labels: `ubuntu-latest` / `default` (plain job pod), `docker` (job pod with privileged DinD sidecar and a 25Gi ephemeral `local-hostpath` volume).
- Job pods have no ServiceAccount token and are restricted by `CiliumNetworkPolicy/forgejo-runner-jobs`
  (DNS, Forgejo :3000, runner cache, envoy-external, Internet 80/443 without private ranges; no ingress).
- The controller only has a namespace-local Role (Jobs, Pods, exec, logs). Do not put unrelated secrets in this namespace.
- Namespace is labelled `pod-security.kubernetes.io/enforce: privileged` because of DinD.
