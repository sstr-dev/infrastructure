# VolSync component

This component currently renders:
- `ExternalSecret/${APP}-volsync`
- `ReplicationSource/${APP}`
- `ReplicationDestination/${APP}-dst`
- `PersistentVolumeClaim/${APP}`

The active implementation lives under `./local` and is Kopia-backed.

## Flux Kustomization

This component expects Flux `postBuild.substitute` values.

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: &app my-app
  namespace: flux-system
spec:
  path: ./kubernetes/apps/main/default/my-app
  postBuild:
    substitute:
      APP: *app
      VOLSYNC_CAPACITY: 5Gi
```

Use the component in the application's `kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
components:
  - ../../../../components/volsync
```

## Required vars

- `APP`: Application name
- `VOLSYNC_CAPACITY`: PVC size

## Optional vars

- `VOLSYNC_ACCESSMODES`: Volume access mode, default `ReadWriteOnce`
- `VOLSYNC_BACKUP_MOVER_FS_GROUP`: Backup mover fsGroup, defaults to `VOLSYNC_MOVER_FS_GROUP`
- `VOLSYNC_BACKUP_MOVER_GROUP`: Backup mover group, defaults to `VOLSYNC_MOVER_GROUP`
- `VOLSYNC_BACKUP_MOVER_USER`: Backup mover user, defaults to `VOLSYNC_MOVER_USER`
- `VOLSYNC_CACHE_ACCESSMODES`: Cache access mode, default `ReadWriteOnce`
- `VOLSYNC_CACHE_CAPACITY`: Cache PVC size, default `1Gi`
- `VOLSYNC_CACHE_STORAGECLASS`: Cache storage class, default `local-hostpath`
- `VOLSYNC_COPYMETHOD`: Copy method, default `Snapshot`
- `VOLSYNC_DAILY`: Daily Kopia retention count, default `7`
- `VOLSYNC_HOURLY`: Hourly Kopia retention count, default `24`
- `VOLSYNC_MOVER_FS_GROUP`: Default mover fsGroup, default `568`
- `VOLSYNC_MOVER_GROUP`: Default mover group, default `568`
- `VOLSYNC_MOVER_USER`: Default mover user, default `568`
- `VOLSYNC_RESTORE_MOVER_FS_GROUP`: Restore mover fsGroup, defaults to `VOLSYNC_MOVER_FS_GROUP`
- `VOLSYNC_RESTORE_MOVER_GROUP`: Restore mover group, defaults to `VOLSYNC_MOVER_GROUP`
- `VOLSYNC_RESTORE_MOVER_USER`: Restore mover user, defaults to `VOLSYNC_MOVER_USER`
- `VOLSYNC_SCHEDULE_LOCAL`: Backup schedule for local, default `0 2 * * *`
- `VOLSYNC_SCHEDULE_REMOTE`: Backup schedule for remote, default `0 2 * * 0`
- `VOLSYNC_SNAPSHOTCLASS`: `VolumeSnapshotClass` name, default `longhorn`
- `VOLSYNC_STORAGECLASS`: StorageClass for temp/restore volumes, default `longhorn`
