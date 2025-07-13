
## Create a Proxmox VE API User

1) Create the API user and set up a dummy password. We'll be creating a token instead

```sh
pveum user add pve-exporter@pve -password "password"
```
2) Assign API permissions:

This command gives the user read-only permissions, which is sufficient for exporting metrics.

```sh
pveum acl modify / -user pve-exporter@pve -role PVEAuditor
```
