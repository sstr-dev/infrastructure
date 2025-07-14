# 🗂️ Namespace: `kube-tools`

This namespace contains operational and support tools for maintaining and optimizing the RKE2 Kubernetes cluster. It includes components for automatic pod restarts, image caching, storage trimming, and pod eviction strategies.

---

## 📦 Included Components

| Application                                                   | Description                                                 | Links                                                                        |
|---------------------------------------------------------------|-------------------------------------------------------------|------------------------------------------------------------------------------|
| [**descheduler**](./descheduler/)                             | Rebalances pods to improve resource efficiency              | [Docs](https://kubernetes.io/docs/concepts/scheduling-eviction/descheduler/) |
| [**fstrim**](./fstrim/)                                       | Periodically issues `fstrim` for mounted PVCs               | [GitHub](https://github.com/angelnu/fstrim-sidecar)                          |
| [**generic-device-plugin**](./generic-device-plugin/)         | Supports custom hardware devices as resources               | [GitHub](https://github.com/squat/generic-device-plugin)                     |
| [**reflector**](./reflector/)                                 | Mirrors Secrets/ConfigMaps across namespaces                | [GitHub](https://github.com/emberstack/kubernetes-reflector)                 |
| [**reloader**](./reloader/)                                   | Reloads Pods when ConfigMaps or Secrets change              | [GitHub](https://github.com/stakater/Reloader)                               |
| [**spegel**](./spegel/)                                       | Mirrors container images to local registry (airgapped envs) | [GitHub](https://github.com/inth3rface/spege)                                |
| [**system-upgrade-controller**](./system-upgrade-controller/) | Handles rolling upgrades of K3s/k3OS clusters               | [Docs](https://rancher.com/docs/k3s/latest/en/upgrades/automated/)           |

---

## 📎 Notes

- Many of these tools are optional but valuable for reliability and automation.
- `reflector` and `reloader` enhance GitOps workflows by syncing and reacting to state changes.
- `fstrim` and `spegel` are ideal for disk optimization and offline usage.
- spegel **Key config:**
  - `containerdSock`: `/run/k3s/containerd/containerd.sock`
  - `containerdRegistryConfigPath`: `/etc/rancher/rke2/registries.yaml`
- fstrim **Typical config:** `fstrim -a -v`

