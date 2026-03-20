# Bootstrap NFS component

This component creates:
- `PersistentVolumeClaim/${BOOTSTRAP_CLAIM:-${APP}}`
- `Job/${BOOTSTRAP_JOB:-${APP}-bootstrap}`

It is intended for one-time seeding from an NFS export into a fresh PVC before the
real application is started.

Use it as a temporary bootstrap step, then remove it after the data has been seeded.

## Required vars

- `APP`: application name
- `BOOTSTRAP_CAPACITY`: PVC size
- `BOOTSTRAP_NFS_SERVER`: NFS server hostname or IP
- `BOOTSTRAP_NFS_PATH`: NFS export path

## Optional vars

- `BOOTSTRAP_ACCESSMODES`: PVC access mode, default `ReadWriteOnce`
- `BOOTSTRAP_CLAIM`: PVC name, default `${APP}`
- `BOOTSTRAP_GROUP`: job container group, default `568`
- `BOOTSTRAP_IMAGE`: container image, default `busybox:1.37.0`
- `BOOTSTRAP_JOB`: job name, default `${APP}-bootstrap`
- `BOOTSTRAP_MARKER`: marker file path in target PVC, default `.bootstrap-complete`
- `BOOTSTRAP_STORAGECLASS`: PVC storage class, default `longhorn`
- `BOOTSTRAP_USER`: job container user, default `568`

## Usage

Add the component to a dedicated bootstrap kustomization, not directly to the main
app deployment. This avoids the app starting before the seed job has completed.

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
components:
  - ../../../../components/bootstrap-nfs
```

Example Flux substitutions:

```yaml
postBuild:
  substitute:
    APP: my-app
    BOOTSTRAP_CAPACITY: 20Gi
    BOOTSTRAP_STORAGECLASS: longhorn
    BOOTSTRAP_NFS_SERVER: nas.main.internal
    BOOTSTRAP_NFS_PATH: /mnt/user/legacy/my-app
```
