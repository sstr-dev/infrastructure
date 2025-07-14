# 🛠️ Infrastructure

This repository contains the **Infrastructure-as-Code (IaC)** setup for my self-hosted environment. It follows the **GitOps** principle to declaratively manage Kubernetes clusters, VMs, cloud services, and automation tooling.

---

## ⚙️ Stack Overview

| Tool           | Purpose                                                 |
|----------------|---------------------------------------------------------|
| **FluxCD**     | GitOps-driven deployment of K8s resources               |
| **Terraform**  | Cloud & networking provisioning (e.g., DNS, servers)    |
| **Ansible**    | Configuration management & system automation            |
| **Kubernetes** | Workload orchestration                                  |
| **Containers** | App delivery via OCI-compatible images                  |
| **Taskfile**   | Automating repetitive shell commands                    |
| **SOPS**       | Encryption of sensitive configuration data              |
| **direnv**     | Automatic environment variable management               |

---

## 📁 Project Structure

```txt
infrastructure/
├── .archive/          # Archived configs or legacy components
├── ansible/           # Playbooks and roles for automation
├── bootstrap/         # Initial cluster & GitOps setup (e.g., flux install)
├── kubernetes/        # K8s resources, organized by environment/namespace
│   ├── apps/          # Application manifests (base, core apps, homelab stack)
│   │   ├── base/
│   │   ├── core/
│   │   └── casa/
│   ├── clusters/      # Cluster-specific definitions (e.g., casa-rke2)
│   ├── components/    # Shared building blocks (e.g., Volumes, ext-auth)
│   ├── config/        # Cluster-level overlays and Kustomize configuration
│   └── vars/          # Cluster-specific variable definitions
├── scripts/           # Helper scripts and automation tools
├── terraform/         # Infrastructure provisioning
├── Taskfile.yaml      # Automation tasks
└── README.md          # You're here!
```

---

## 🚀 Usage

This infrastructure is managed via GitOps (Flux) and operationalized using `task`, `helmfile`, and supporting tools.

---

### 🧰 1. Prepare Your Workstation

Install all necessary tools and configure your local environment:

```bash
# Setup direnv (.envrc support)
task workstation:direnv

# Setup Python virtualenv + dependencies
task workstation:venv

# Install helm-diff plugin (required by helmfile)
helm plugin install https://github.com/databus23/helm-diff

# Setup Ansible
task ansible:deps
```

Make sure the following tools are available in your `$PATH`:

- `flux`
- `helm` + `helm-diff`
- `helmfile`
- `task`
- `age` (or `gopass`, if used)
- `terraform`
- `ansible`
- `sops`

---

### 🧪 2. Verify Your Secrets (optional)

Make sure SOPS can decrypt your cluster (e.g.: core) secrets:

```bash
sops -d kubernetes/vars/core/cluster-secrets.sops.yaml
```

If you’re using `direnv`, private keys can be loaded automatically from `.envrc`.

---

### 🚀 3. Bootstrap or Reconcile a Cluster

Deploy base components (via Flux + Helmfile):

```bash
task flux:bootstrap cluster=core-rke2
task flux:helmfile cluster=core-rke2
```

You can also target a different cluster:

```bash
task flux:helmfile cluster=casa-rke2
```

---

### 📦 4. Apply Infrastructure (Terraform & Ansible)

Provision resources like DNS, S3, servers:
<!--
```bash
cd terraform/environments/homelab
terraform init
terraform apply
```

Then configure machines or remote services with Ansible:

```bash
ansible-playbook -i ansible/inventory/homelab.yml site.yml
```
-->
---

### 🔁 5. GitOps Loop

Once bootstrapped, Flux will take over:

- Watches for changes in `kubernetes/clusters/<name>/`
- Applies HelmReleases, Kustomizations, secrets, etc.
- Enables you to manage infrastructure via Git alone

---

## 🔒 Secrets Management

* Sensitive data is encrypted using **[SOPS](https://github.com/mozilla/sops)**.
* Configuration is managed via `.sops.yaml`.
* You need [age](https://github.com/FiloSottile/age) keys to decrypt.
* CI/Flux decrypts secrets via external vaults.

---

## 🧪 Useful Tasks

```bash
# List available tasks
task --list

# Monitor deployment for cluster casa-rke2
task flux:monitor cluster=casa-rke2
```

---

## 📦 Requirements

- [Flux CLI](https://fluxcd.io/)
- [Terraform](https://terraform.io/)
- [Ansible](https://www.ansible.com/)
- [SOPS](https://github.com/mozilla/sops)
- [Age](https://github.com/FiloSottile/age)
- [Task](https://taskfile.dev/)
- [Helm + helm-diff plugin](https://github.com/databus23/helm-diff)

---

## 📖 Docs & References

- [FluxCD Docs](https://fluxcd.io/docs/)
- [Terraform Docs](https://developer.hashicorp.com/terraform)
- [Ansible Docs](https://docs.ansible.com/)
- [SOPS Docs](https://github.com/mozilla/sops#documentation)

---

## 🧾 License

[MIT License](./LICENSE)

---

## 📎 Notes

* Disabled components are moved to the `.archive/` directory.
* Replace all secrets and domains with your own for production use.

---

Built with ❤️ for infrastructure that just works.
