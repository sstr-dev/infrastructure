# Nextcloud Maintenance

Common maintenance commands for the Nextcloud deployment.

## Upgrade Nextcloud

After updating the Nextcloud container image, execute the database migrations and upgrade steps inside the running container.

```bash
su -s /bin/sh www-data -c 'php occ upgrade'
````

## Update All Apps

```bash
su -s /bin/sh www-data -c 'php occ app:update --all'
```

## Kubernetes Example

Execute the upgrade command in a running pod:

```bash
kubectl exec -it <nextcloud-pod> -- \
  su -s /bin/sh www-data -c 'php occ upgrade'
```
