# Kopiur component

Reusable Kustomize component that adds Kopiur snapshot, restore, and PVC resources to an application.

Add the component to the application's `kustomization.yaml`, then provide `APP` and optional `KOPIUR_*` values through the Flux `Kustomization`:

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
spec:
  path: ./kubernetes/apps/base/example
  postBuild:
    substitute:
      APP: example
      KOPIUR_CAPACITY: 10Gi
      KOPIUR_STORAGECLASS: longhorn
```

```yaml
# kubernetes/apps/base/example/kustomization.yaml
components:
  - ../../../components/kopiur
```

## Variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `KOPIUR_CLAIM` | `APP` | PVC name |
| `KOPIUR_ACCESSMODES` | `ReadWriteOnce` | PVC access mode |
| `KOPIUR_CAPACITY` | `5Gi` | PVC and mover-cache capacity |
| `KOPIUR_STORAGECLASS` | `longhorn` | Application PVC storage class |
| `KOPIUR_CACHE_STORAGECLASS` | `longhorn-cache` | Mover-cache storage class (local-hostpath is also an option) |
| `KOPIUR_SNAPSHOTCLASS` | `longhorn-snapclass` | VolumeSnapshotClass used by the policy |
| `KOPIUR_PUID` | `1000` | Mover container user ID |
| `KOPIUR_PGID` | `1000` | Mover container group and filesystem group ID |

Values omitted from `postBuild.substitute` use the defaults above. `APP` is required and names the generated resources and source PVC.
