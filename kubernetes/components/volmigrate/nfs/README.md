# Volmigrate NFS component

This component currently creates:
- `Job/${BOOTSTRAP_JOB:-${APP}-bootstrap}`

It is intended for one-time seeding from an NFS export into an existing PVC before
the real application is started.

Use it as a temporary migration step, then remove it after the data has been seeded.

## Required vars

- `APP`: application name
- `BOOTSTRAP_NFS_SERVER`: NFS server hostname or IP, default `nas.main.internal`
- `BOOTSTRAP_NFS_PATH`: NFS export path, default `/mnt/user/legacy/${APP}`

## Optional vars

- `BOOTSTRAP_CLAIM`: PVC name, default `${APP}`
- `BOOTSTRAP_DEBUG_SLEEP`: sleep in seconds before the copy starts, default `0`
- `BOOTSTRAP_IMAGE`: container image, default `busybox:1.37.0`
- `BOOTSTRAP_JOB`: job name, default `${APP}-bootstrap`
- `BOOTSTRAP_MARKER`: marker file path in target PVC, default `.bootstrap-complete`

## Usage

The intended pattern is a dedicated migration Flux `Kustomization` using the empty
build root at `./kubernetes/migration/common`.

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: my-app-migrate
spec:
  path: ./kubernetes/migration/common
  components:
    - ../../../../components/volmigrate/nfs
```

If you also want the normal VolSync resources during migration, add:

```yaml
  components:
    - ../../../../components/volsync
    - ../../../../components/volmigrate/nfs
```

Example Flux substitutions:

```yaml
postBuild:
  substitute:
    APP: my-app
    BOOTSTRAP_CLAIM: my-app
    BOOTSTRAP_NFS_SERVER: nas.main.internal
    BOOTSTRAP_NFS_PATH: /mnt/user/legacy/my-app
```

## Notes
- use `cp -av source nfstarget` to copy files
- set `BOOTSTRAP_DEBUG_SLEEP` to keep the pod idle before copying, for example `300`
- the job currently runs as root because no pod `securityContext` is set
