# 🗂️ Namespace: `storage-system`

This namespace provides persistent and ephemeral storage capabilities for the Kubernetes cluster. It includes CSI drivers, object storage, volume snapshots, and file-sharing services.

---

## 📦 Included Components

| Application                                             | Description                                            | Links                                                                                              |
|---------------------------------------------------------|--------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| [**democratic-csi**](./democratic-csi/)                 | CSI driver for NFS, iSCSI, SMB, ZFS, and more          | [Website](https://democratic-csi.github.io) [GitHub](https://github.com/democratic-csi/csi-driver) |
| [**local-path-provisioner**](./local-path-provisioner/) | Local dynamic storage provisioner                      | [GitHub](https://github.com/rancher/local-path-provisioner)                                        |
| [**minio**](./minio/)                                   | S3-compatible high-performance object storage          | [Website](https://min.io) [GitHub](https://github.com/minio/minio)                                 |
| [**samba**](./samba/)                                   | SMB file server for Linux and Windows interoperability | [Website](https://www.samba.org)                                                                   |
| [**snapshot-controller**](./snapshot-controller/)       | Native Kubernetes controller for volume snapshots      | [K8s Docs](https://kubernetes.io/docs/concepts/storage/volume-snapshots/)                          |

---

## 📎 Notes

- `democratic-csi` can integrate with TrueNAS, Synology, and other platforms.
- `minio` is useful as a lightweight S3 backend for backup and artifact storage.
- Ensure PVCs are properly backed by CSI drivers or external storage solutions.
- `snapshot-controller` requires VolumeSnapshotClass definitions to be functional.
