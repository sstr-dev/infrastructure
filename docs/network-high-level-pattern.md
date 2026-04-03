# High-Level Network Pattern

This diagram shows a reusable high-level network pattern for Kubernetes clusters in this repository. The `main` cluster acts as the reference implementation, while `test` and `registry` are planned variants with a smaller footprint and cluster-specific service exposure.

```mermaid
flowchart TB
    internet["Internet / Clients"]
    cloudflare["Cloudflare Edge"]
    router["Gateway / Router<br/>10.0.60.1"]

    subgraph networks["Shared network layers"]
        lan60["Server network<br/>API endpoints, control plane,<br/>internal LB services"]
        lan69["Service and LB network<br/>external gateway VIPs,<br/>announced service IPs"]
    end

    subgraph platform["Reusable cluster platform pattern"]
        talos["Talos nodes<br/>control plane and workers"]
        cilium["Cilium<br/>CNI, LB IPAM, L2 announce"]
        gateways["Envoy Gateway<br/>internal, external, public"]
        dns["ExternalDNS and Cloudflare Tunnel<br/>DNS and optional tunnel ingress"]
        routing["HTTP and HTTPS routing<br/>to cluster workloads"]
    end

    subgraph clusters["Cluster variants"]
        subgraph main["Cluster: main"]
            mainShape["Full-size reference cluster<br/>3 control plane, 3 workers"]
        end

        subgraph test["Cluster: test"]
            testShape["Smaller validation cluster<br/>planned reduced node count"]
        end

        subgraph registry["Cluster: registry"]
            registryShape["Reduced-footprint cluster<br/>planned single node"]
        end
    end

    gitops["FluxCD / GitOps"]
    workloads["Cluster workloads"]

    internet --> cloudflare
    internet --> router

    router --> lan60
    router --> lan69

    cloudflare -->|DNS and public access| dns
    cloudflare -->|Optional tunnel| dns

    lan60 --> talos
    lan69 --> cilium

    talos --> cilium
    cilium --> gateways
    dns --> gateways
    gateways --> routing
    routing --> workloads

    gitops --> main
    gitops --> test
    gitops --> registry

    main --> talos
    test --> talos
    registry --> talos

    workloads --> main
    workloads --> test
    workloads --> registry
```

## Summary

- The diagram represents a reusable cluster pattern rather than an exact one-to-one inventory of a single environment.
- The same core building blocks can be reused across clusters: Talos, Cilium, Envoy Gateway, ExternalDNS, and optional Cloudflare Tunnel exposure.
- `main` is the reference implementation, while `test` and `registry` are smaller planned variants of the same overall pattern.
- The server network typically carries cluster API endpoints, control-plane traffic, and internal LoadBalancer services.
- The service and LB network typically carries externally announced gateway VIPs and service IP pools.
- The diagram is intentionally simplified for architecture documentation and presentations, not for node-by-node operational detail.

