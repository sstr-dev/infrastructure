# Infrastructure

This repository contains the Infrastructure-as-Code setup for a self-hosted platform built around Talos, Kubernetes, and GitOps. It combines cluster bootstrap, platform apps, secrets handling, and day-two operations in one repo.

---

## What Lives Here

- `talos/`
  Talos machine configuration, node definitions, schematics, and generated cluster access material.

- `bootstrap/`
  Bootstrap-specific values and manifests used during initial cluster bring-up.

- `kubernetes/`
  GitOps-managed cluster state:
  - `apps/base/` for reusable base apps and patterns
  - `apps/main/`, `apps/test/`, `apps/registry/` for cluster-specific app entrypoints
  - `clusters/` for Flux entrypoints per cluster
  - `components/` for shared Kustomize components
  - `vars/` for cluster settings and encrypted cluster secrets

- `.taskfiles/`
  Operational command surface grouped by concern such as `talos`, `flux`, `database`, `sops`, `vault`, and `workstation`.

- `ansible/`
  Supporting automation for systems outside the narrower GitOps flow.

- `terraform/`
  Infrastructure provisioning for resources that live outside Kubernetes.

- `.github/workflows/`
  Repository automation for maintenance tasks like Renovate, label sync, labeler, and bulk PR merges.

- `docs/`
  Architecture patterns, platform references, and operational guides.

---

## How To Start

The normal path is: prepare your workstation, ensure secrets can be decrypted, bootstrap Talos if needed, then hand over workload delivery to GitOps.

### 1. Prepare Your Workstation

Install the required tools first. The repo expects tools like `task`, `direnv`, `sops`, `age`, `kubectl`, `helm`, `helmfile`, `flux`, `talosctl`, `jq`, `yq`, `python3.11`, and optionally `ansible` and `terraform`.

Common setup commands:

```bash
task workstation:direnv
task workstation:venv
task ansible:deps
```

If you use Homebrew on macOS, there is also:

```bash
task workstation:brew
task workstation:krew
```

To see the available command surface at any time:

```bash
task --list
```

### 2. Prepare Secrets

The repo uses SOPS with Age keys.

Generate a local Age key if you do not already have one:

```bash
task sops:age-keygen
```

Validate that decryption works before doing cluster operations:

```bash
sops -d kubernetes/vars/main/cluster-secrets.sops.yaml >/dev/null
```

By default the Taskfiles expect the key at `./age.key` via `SOPS_AGE_KEY_FILE`.

### 3. Bootstrap A Cluster

For a fresh Talos cluster:

```bash
task talos:bootstrap cluster=main
task talos:kubeconfig cluster=main
task talos:apps cluster=main
```

Important clusters currently represented in this repo:

- `main`
- `test`
- `registry`

The `talos:*` tasks cover initial machine bootstrap and cluster access generation. After that, app/platform delivery is handled from `kubernetes/` through Flux and Kustomize.

### 4. Bootstrap Or Reconcile GitOps

If the cluster already exists and you want to push the app/platform layer:

```bash
task flux:helmfile cluster=main
task flux:reconcile cluster=main
task flux:monitor cluster=main
```

Useful day-two sync helpers:

```bash
task flux:ks-sync cluster=main
task flux:gr-sync cluster=main
task flux:hr-sync cluster=main
```

### 5. Operate The Platform

Examples:

```bash
task talos:apply-cluster cluster=main
task talos:reboot-node cluster=main node=wk01.k8s.main.internal
task db:overview cluster=main
task db:cnpg:clusters cluster=main
```

The most useful operational references live in [`docs/operations/operations-guide.md`](./docs/operations/operations-guide.md) and [`docs/operations/taskfiles-pattern.md`](./docs/operations/taskfiles-pattern.md).

---

## Repository Structure

```txt
infrastructure/
|- .github/             # GitHub metadata and repository workflows
|- .taskfiles/          # Task namespaces for ops workflows
|- ansible/             # Supporting automation
|- bootstrap/           # Bootstrap-time config per cluster
|- docs/                # Architecture, operations, and reference docs
|- kubernetes/          # GitOps-managed Kubernetes resources
|  |- apps/             # Base and cluster-specific app definitions
|  |- clusters/         # Flux entrypoints per cluster
|  |- components/       # Shared Kustomize components
|  `- vars/             # Cluster settings and encrypted secrets
|- scripts/             # Helper scripts used by tasks/bootstrap flows
|- talos/               # Talos cluster and node configuration
|- terraform/           # Non-Kubernetes infrastructure provisioning
|- Taskfile.yaml        # Root operational entrypoint
`- README.md            # This file
```

---

## GitHub Workflows

This repository currently uses GitHub Actions mainly for repository maintenance, not for primary cluster delivery.

- `renovate.yaml`
  Runs Renovate on schedule or manually.

- `label-sync.yaml`
  Syncs labels from `.github/labels.yaml`.

- `labeler.yaml`
  Applies PR labels based on changed files.

- `bulk-merge-prs.yaml`
  Manual workflow for merging selected PR batches.

Cluster delivery itself is driven from inside the platform through Flux watching this repository.

---

## Working Model

- Talos bootstraps the cluster nodes and Kubernetes control plane.
- Flux reconciles manifests from `kubernetes/clusters/<cluster>/`.
- Cluster app entrypoints in `kubernetes/apps/<cluster>/` compose shared base definitions from `kubernetes/apps/base/` and `kubernetes/components/`.
- Secrets are kept encrypted with SOPS or injected at runtime through external secret backends.
- Day-two changes should generally flow through Git and Flux, with `task` commands used for bootstrap, diagnostics, and controlled imperative operations.

---

## Recommended Reading

- [`docs/README.md`](./docs/README.md)
- [`docs/architecture/cluster-bootstrap-pattern.md`](./docs/architecture/cluster-bootstrap-pattern.md)
- [`docs/architecture/gitops-delivery-pattern.md`](./docs/architecture/gitops-delivery-pattern.md)
- [`docs/operations/operations-guide.md`](./docs/operations/operations-guide.md)

---

## Docs & References

- [Flux documentation](https://fluxcd.io/flux/)
- [Talos Linux documentation](https://www.talos.dev/)
- [Kubernetes documentation](https://kubernetes.io/docs/)
- [SOPS documentation](https://github.com/getsops/sops)
- [Age documentation](https://github.com/FiloSottile/age)
- [Task documentation](https://taskfile.dev/)
- [Helm documentation](https://helm.sh/docs/)
- [Helmfile documentation](https://helmfile.readthedocs.io/)
- [Ansible documentation](https://docs.ansible.com/)
- [Terraform documentation](https://developer.hashicorp.com/terraform)

---

## Notes

- Some historical or disabled material is kept in `.archive/` or `.trash/`.
- Validate encrypted files before committing with:

```bash
task repository:validate
```

---

## License

[MIT License](./LICENSE)

---

Built with ❤️ for infrastructure that just works.
