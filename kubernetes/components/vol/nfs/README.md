# Vol NFS component

This component creates a static NFS-backed volume pair for an application:
- `PersistentVolume/${CLAIM:-${APP}}`
- `PersistentVolumeClaim/${CLAIM:-${APP}}`

It is intended for workloads that should bind to a known NFS export and subfolder.

The `./two` variant provides a second independent NFS-backed PV/PVC pair for the same
application by using `*_2` variables.

## Usage

Use the component in the application's `kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
components:
  - ../../../../components/vol/nfs
```

Example Flux `Kustomization` with substitutions:

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: &app my-app
spec:
  path: ./kubernetes/apps/main/default/my-app
  postBuild:
    substitute:
      APP: *app
      VOL_CAPACITY: 5Gi
      NFS_SERVER: nas.main.internal
      NFS_PATH: /mnt/user/applications
      NFS_SUBFOLDER: my-app
```

## Required vars

- `APP`: Application name

## Optional vars

- `CLAIM`: PV and PVC name, default `${APP}`
- `NFS_PATH`: Base NFS export path, default `/mnt/user/applications`
- `NFS_SERVER`: NFS server hostname or IP, default `nas.main.internal`
- `NFS_SUBFOLDER`: Subfolder below `NFS_PATH`, default `${APP}`
- `VOL_ACCESSMODES`: Access mode, default `ReadWriteMany`
- `VOL_CAPACITY`: Requested PVC size, default `5Gi`

## Second volume variant

Use `./two` when the application needs a second static NFS mount:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
components:
  - ../../../../components/vol/nfs
  - ../../../../components/vol/nfs/two
```

Optional variables for the second volume:

- `CLAIM_2`: Second PV and PVC name, default `${APP}-2`
- `NFS_PATH_2`: Base NFS export path, defaults to `NFS_PATH`
- `NFS_SERVER_2`: NFS server hostname or IP, defaults to `NFS_SERVER`
- `NFS_SUBFOLDER_2`: Subfolder below `NFS_PATH_2`, defaults to `NFS_SUBFOLDER`
- `VOL_ACCESSMODES_2`: Access mode, defaults to `VOL_ACCESSMODES`
- `VOL_CAPACITY_2`: Requested PVC size, defaults to `VOL_CAPACITY`
