# 🗂️ Namespace: `kube-tools`

This namespace contains operational and support tools for maintaining and optimizing the RKE2 Kubernetes cluster. It includes components for automatic pod restarts, image caching, storage trimming, and pod eviction strategies.

---

## 📦 Installed Tools

### 🔁 Reloader
- **Purpose:** Watches for changes in ConfigMaps and Secrets, and triggers rolling restarts on affected Deployments, StatefulSets, and DaemonSets.
- **Use case:** Ensures applications automatically reload configuration changes without manual intervention.
- **Docs:** https://github.com/stakater/Reloader

---

### 🪞 Spegel
- **Purpose:** OCI registry mirror/cache that reflects remote images locally within the cluster.
- **Use case:** Speeds up image pulls, reduces reliance on public registries, and supports air-gapped or private environments.
- **Key config:**
  - `containerdSock`: `/run/k3s/containerd/containerd.sock`
  - `containerdRegistryConfigPath`: `/etc/rancher/rke2/registries.yaml`
- **Docs:** https://github.com/inth3rface/spegel

---

### 🧹 fstrim (cronjob or DaemonSet)
- **Purpose:** Trims unused storage blocks to improve disk usage efficiency and performance, especially with thin-provisioned volumes (e.g., LVM, longhorn, etc.).
- **Use case:** Runs on a schedule or manually to reclaim disk space and inform the storage backend.
- **Typical config:** `fstrim -a -v`

---

### 📤 Descheduler
- **Purpose:** Periodically evicts pods to help re-balance workloads in the cluster based on policies (e.g., remove duplicates, low node utilization).
- **Use case:** Improves scheduling fairness, reduces skewed pod distribution, and helps recover from degraded node conditions.
- **Docs:** https://github.com/kubernetes-sigs/descheduler

---

