# Documentation Index

This folder contains architecture notes, reference documents, and reusable platform patterns for this repository.

## High-Level Building Blocks

### Architecture Map

```mermaid
flowchart LR
    bootstrap["Cluster bootstrap"]
    gitops["GitOps delivery"]
    apps["Application delivery"]
    exposure["Ingress and service exposure"]
    data["Data platform"]
    ops["Operations"]
    identity["Identity and secrets"]

    bootstrap --> gitops
    gitops --> apps
    apps --> exposure
    apps --> data

    identity -. supports .-> bootstrap
    identity -. supports .-> apps
    identity -. supports .-> exposure
    identity -. supports .-> data

    ops -. operates .-> gitops
    ops -. operates .-> apps
    ops -. operates .-> exposure
    ops -. operates .-> data
```

### Document Mapping

```mermaid
flowchart LR
    bootstrap["Cluster bootstrap"]
    gitops["GitOps delivery"]
    apps["Application delivery"]
    exposure["Ingress and service exposure"]
    data["Data platform"]
    identity["Identity and secrets"]
    ops["Operations"]

    bootstrapDocs["cluster-bootstrap-pattern<br/>cluster-variants"]
    gitopsDocs["gitops-delivery-pattern"]
    appDocs["application-pattern"]
    exposureDocs["network-high-level-pattern<br/>ingress-and-service-exposure-pattern"]
    dataDocs["database-pattern<br/>storage-and-backup-pattern"]
    identityDocs["secret-management-pattern<br/>identity-and-access-pattern"]
    opsDocs["operations-guide"]

    bootstrap --> bootstrapDocs
    gitops --> gitopsDocs
    apps --> appDocs
    exposure --> exposureDocs
    data --> dataDocs
    identity --> identityDocs
    ops --> opsDocs
```

## Architecture Patterns

- [`network-high-level-pattern.md`](./network-high-level-pattern.md)
  Reusable high-level network pattern for clusters such as `main`, `test`, and `registry`.

- [`secret-management-pattern.md`](./secret-management-pattern.md)
  Pattern for handling bootstrap secrets, Vault-backed runtime secrets, and template-time secret injection.

- [`application-pattern.md`](./application-pattern.md)
  Pattern for how a typical app is structured, parameterized, exposed, and connected to secrets and storage.

- [`cluster-bootstrap-pattern.md`](./cluster-bootstrap-pattern.md)
  Pattern for bringing up a cluster from Talos templates through initial platform bootstrap and GitOps handover.

- [`cluster-variants.md`](./cluster-variants.md)
  Summary of how `main`, `test`, and `registry` relate to the shared platform pattern.

- [`gitops-delivery-pattern.md`](./gitops-delivery-pattern.md)
  Pattern for bootstrap, Flux reconciliation, and layered application delivery.

- [`identity-and-access-pattern.md`](./identity-and-access-pattern.md)
  Pattern for Authentik, LLDAP, gateway auth policies, and app-level OIDC integration.

- [`ingress-and-service-exposure-pattern.md`](./ingress-and-service-exposure-pattern.md)
  Pattern for Envoy Gateway, service exposure, DNS automation, TLS, and Cloudflare integration.

- [`database-pattern.md`](./database-pattern.md)
  Pattern for CloudNativePG, MariaDB, Dragonfly, database access, and database-specific backups.

- [`storage-and-backup-pattern.md`](./storage-and-backup-pattern.md)
  Pattern for persistent storage, replication, object storage, and backup workflows.

## Operations

- [`operations-guide.md`](./operations-guide.md)
  Compact index of common bootstrap, Flux, Talos, and database operations.

## Reference Documents

- [`redis-db-usage.md`](./redis-db-usage.md)
  Notes about Redis database usage and allocation.

- [`network-ip-usage.md`](./network-ip-usage.md)
  Inventory of network ranges, VIPs, service IPs, and node addresses.

## Suggested Reading Order

1. [`network-high-level-pattern.md`](./network-high-level-pattern.md)
2. [`secret-management-pattern.md`](./secret-management-pattern.md)
3. [`cluster-bootstrap-pattern.md`](./cluster-bootstrap-pattern.md)
4. [`gitops-delivery-pattern.md`](./gitops-delivery-pattern.md)
5. [`cluster-variants.md`](./cluster-variants.md)
6. [`application-pattern.md`](./application-pattern.md)
7. [`identity-and-access-pattern.md`](./identity-and-access-pattern.md)
8. [`ingress-and-service-exposure-pattern.md`](./ingress-and-service-exposure-pattern.md)
9. [`database-pattern.md`](./database-pattern.md)
10. [`storage-and-backup-pattern.md`](./storage-and-backup-pattern.md)

## Notes

- Pattern documents describe reusable architectural approaches, not exact one-to-one inventories.
- Reference documents capture concrete values, allocations, or implementation-specific details.
