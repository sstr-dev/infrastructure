# Namespace: `kube-tools`

This namespace contains operational helpers and cluster support tooling.

## Components

| Application | Description | Links |
|-------------|-------------|-------|
| [descheduler](./descheduler/) | Rebalances pods to improve scheduling efficiency | [Docs](https://kubernetes.io/docs/concepts/scheduling-eviction/descheduler/) |
| [fstrim](./fstrim/) | Periodic filesystem trim support for storage workloads | [GitHub](https://github.com/angelnu/fstrim-sidecar) |
| [generic-device-plugin](./generic-device-plugin/) | Exposes custom hardware devices as schedulable resources | [GitHub](https://github.com/squat/generic-device-plugin) |
| [nvidia-device-plugin](./nvidia-device-plugin/) | Exposes NVIDIA GPUs to Kubernetes workloads | [GitHub](https://github.com/NVIDIA/k8s-device-plugin) |
| [reflector](./reflector/) | Mirrors Secrets and ConfigMaps across namespaces | [GitHub](https://github.com/emberstack/kubernetes-reflector) |
| [reloader](./reloader/) | Restarts workloads when ConfigMaps or Secrets change | [GitHub](https://github.com/stakater/Reloader) |
| [spegel](./spegel/) | Peer-to-peer image mirroring for container images | [GitHub](https://github.com/spegel-org/spegel) |
| [system-upgrade-controller](./system-upgrade-controller/) | Controller for coordinated node upgrade workflows | [GitHub](https://github.com/rancher/system-upgrade-controller) |
