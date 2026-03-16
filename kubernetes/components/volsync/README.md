# VolSync Component

This component creates a VolSync setup backed by a Kopia repository.

It includes:
- an `ExternalSecret` for the Kopia repository credentials
- a `ReplicationSource`
- a `ReplicationDestination`
- a restore `PersistentVolumeClaim`

## Variables

Required:
- `APP`: Base name for all generated resources

Optional:
- `VOLSYNC_ACCESSMODES` default: `ReadWriteOnce`
- `VOLSYNC_SNAP_ACCESSMODES` default: `ReadWriteOnce`
- `VOLSYNC_STORAGECLASS` default: `longhorn-volsync`
- `VOLSYNC_SNAPSHOTCLASS` default: `longhorn`
- `VOLSYNC_CAPACITY` default: `5Gi`
- `VOLSYNC_CACHE_CAPACITY` default: `8Gi`
- `VOLSYNC_CACHE_STORAGECLASS` default: `local-hostpath`
- `VOLSYNC_PUID` default: `1000`
- `VOLSYNC_PGID` default: `1000`

## Generated Resources

For `APP=my-app`, this component creates:
- secret target: `my-app-volsync-secret`
- replication source: `my-app-src`
- replication destination: `my-app-dst`
- restore PVC: `my-app`

## Secret Data

The generated secret contains:
- `KOPIA_REPOSITORY=filesystem:///repository`
- `KOPIA_FS_PATH=/repository`
- `KOPIA_PASSWORD`

The external secret reads from:
- `${CLUSTER}/volsync-template`

## Usage

Add the component to an application kustomization and provide at least `APP`.

Base app `kustomization.yaml` example:

```yaml
---
# yaml-language-server: $schema=https://json.schemastore.org/kustomization
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ./helmrelease.yaml
components:
  - ../../../components/volsync
```

Flux `Kustomization` example:

```yaml
---
# yaml-language-server: $schema=https://kube-schemas.pages.dev/kustomize.toolkit.fluxcd.io/kustomization_v1.json
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: &app my-app
spec:
  path: ./kubernetes/apps/base/my-app
  postBuild:
    substitute:
      APP: *app
      VOLSYNC_CAPACITY: 20Gi
      VOLSYNC_STORAGECLASS: longhorn-volsync
      VOLSYNC_SNAPSHOTCLASS: longhorn
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
    namespace: flux-system
  wait: false
```

The common repo pattern is:
- add the component in the app base
- provide `APP` and optional `VOLSYNC_*` values through Flux `postBuild.substitute`
