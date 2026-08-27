# Troubleshooting tasks

These tasks inspect common Flux and Envoy Gateway failures. The default cluster
context is `main`; override it with `cluster=<context>`.

## Diagnostics

- `task doctor:flux` lists Flux Kustomizations and HelmReleases.
- `task doctor:helm ns=<namespace> name=<release>` inspects a HelmRelease, pods,
  and recent namespace events.
- `task doctor:kustomization ns=<namespace> name=<name>` inspects a Flux
  Kustomization and recent events.
- `task doctor:envoy ns=<namespace> name=<route>` inspects an HTTPRoute and
  recent Envoy Gateway controller errors. Use `since=30m` to change the window.

## Remediation

- `task doctor:helm-retry ns=<namespace> name=<release>` resets a stalled
  HelmRelease, requests reconciliation, and waits until it is ready.
- `task doctor:kustomization-retry ns=<namespace> name=<name>` requests
  reconciliation and waits until the Kustomization is ready.

Remediation tasks prompt for confirmation. Override the default `10m` wait with
`timeout=<duration>`.
