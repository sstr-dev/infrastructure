# Terraform

This directory is reserved for infrastructure that is managed outside Kubernetes.

The long-term target for this repository is to use OpenTofu for declarative infrastructure such as:

- Proxmox VM provisioning
- DNS and edge records
- other external infrastructure primitives that should not be owned by Flux

Responsibilities should stay split like this:

- `terraform/`: external infrastructure provisioning
- `talos/`: Talos and cluster node configuration
- `kubernetes/`: in-cluster apps and platform services
- `ansible/`: host setup and imperative tasks where needed

