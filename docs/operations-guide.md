# Operations Guide

This document provides a compact operational index for common day-two workflows in this repository.

## Cluster Bootstrap

- Bootstrap Talos and Kubernetes:
  `task talos:bootstrap cluster=main`

- Bootstrap cluster apps:
  `task talos:apps cluster=main`

- Regenerate kubeconfig:
  `task talos:kubeconfig cluster=main`

## Flux Operations

- Reconcile the main Flux entrypoint:
  `task flux:reconcile cluster=main`

- Monitor Kustomizations and HelmReleases:
  `task flux:monitor cluster=main`

- Trigger all Flux Kustomizations:
  `task flux:ks-sync cluster=main`

- Trigger all Flux GitRepositories:
  `task flux:gr-sync cluster=main`

- Trigger all Flux HelmReleases:
  `task flux:hr-sync cluster=main`

## Talos Operations

- Apply a single node config:
  `task talos:apply-node cluster=main node=cp01.k8s.main.internal`

- Apply the cluster config to all nodes:
  `task talos:apply-cluster cluster=main`

- Reboot a node:
  `task talos:reboot-node cluster=main node=wk01.k8s.main.internal`

- Show disks:
  `task talos:disks cluster=main node=wk01.k8s.main.internal`

- Show volume status:
  `task talos:volumestatus cluster=main node=wk01.k8s.main.internal`

- Open the Talos dashboard:
  `task talos:dashboard cluster=main`

## Database Operations

- Overview:
  `task db:overview cluster=main`

- List CNPG clusters:
  `task db:cnpg:clusters cluster=main`

- Trigger a CNPG backup:
  `task db:cnpg:backup cluster=main`

- Open `psql`:
  `task db:cnpg:psql cluster=main`

- List MariaDB resources:
  `task db:mariadb:clusters cluster=main`

## Operational References

- Talos task details live in [`.taskfiles/Talos/README.md`](../.taskfiles/Talos/README.md).
- Database task details live in [`.taskfiles/Database/README.md`](../.taskfiles/Database/README.md).
- GitOps task details live in [`.taskfiles/Flux/Taskfile.yaml`](../.taskfiles/Flux/Taskfile.yaml).

## Notes

- Pattern and bootstrap changes should generally flow through Git after the cluster is operational.
- Destructive operations such as Talos reset should be used deliberately and only when the impact is understood.
