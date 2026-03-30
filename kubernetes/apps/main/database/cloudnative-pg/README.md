# CloudNativePG Notes

This directory contains the CloudNativePG cluster definitions.

## Replica Stuck In Startup

One failure mode we have seen is a replica pod staying in `Running` but never becoming `Ready`.
The CloudNativePG cluster may show a status like:

- `Waiting for the instances to become active`
- `READY 2/3`

The affected pod may repeatedly log messages like:

- `Instance is still down, will retry in 1 second`
- `the database system is starting up`
- `primary server contains no more WAL on requested timeline`
- `waiting for WAL to become available`

This usually means the replica PVC contains old recovery state from a previous timeline, and the replica can no longer catch up cleanly after a promotion or failover.

## Diagnose

Check cluster and pod status:

```bash
kubectl -n database get cluster postgres
kubectl -n database get pods -l cnpg.io/cluster=postgres
kubectl -n database describe pod <replica-pod>
kubectl -n database logs <replica-pod> -c postgres --tail=200
```

Useful signs that this is a stale replica volume problem:

- the primary is healthy
- one replica is stuck in startup
- the stuck replica logs mention WAL/timeline mismatch
- the stuck replica is using an older PVC with existing data

## Recovery

Only do this for a replica, never for the current primary.

Delete the stuck replica pod and its PVC so CloudNativePG can seed a fresh replica from the current primary:

```bash
kubectl -n database delete pod <replica-pod>
kubectl -n database delete pvc <replica-pvc>
```

Example:

```bash
kubectl -n database delete pod postgres-4
kubectl -n database delete pvc postgres-4
```

CloudNativePG will usually create a new replica with the next node serial, for example `postgres-5`.

## Verify Recovery

Watch the cluster until all instances are ready again:

```bash
kubectl -n database get cluster postgres -w
kubectl -n database get pods -l cnpg.io/cluster=postgres -w
```

Expected end state:

- cluster status becomes `Cluster in healthy state`
- `READY` returns to `3/3`
- the replacement replica becomes `2/2 Running`

## Notes

- Do not delete the PVC of the current primary.
- If more than one instance is unhealthy, inspect the primary before deleting anything.
- If logs suggest image, storage, or permission problems instead of WAL recovery issues, investigate those first.
