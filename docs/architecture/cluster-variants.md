# Cluster Variants

This document summarizes the intended cluster variants that share the same overall platform pattern in this repository.

## Overview

- `main`
  Reference implementation and primary workload cluster.

- `test`
  Planned reduced-size validation cluster for experiments, rollout checks, and pattern testing.

- `registry`
  Planned minimal-footprint cluster focused on registry-oriented or specialized workloads.

## Shared Pattern

- Talos-based node management
- Flux-driven GitOps reconciliation
- Cilium networking and LoadBalancer IP management
- Envoy Gateway-based HTTP and HTTPS exposure
- Vault-backed secret delivery
- Reusable application and storage patterns

## Expected Differences

- Node count and role distribution
- Which apps are deployed
- Which gateways and public endpoints are exposed
- Which storage and backup capabilities are required
- Whether some components are reduced, omitted, or single-node only

## Current Positioning

- `main` is the concrete reference cluster represented by most current repo state.
- `test` and `registry` are planned variants that are expected to reuse the same architecture with a smaller footprint.
- Pattern documents in this folder should generally be read as reusable design guidance, not as `main`-only descriptions unless explicitly stated.

## Design Intent

- Keep architecture decisions reusable across clusters.
- Allow smaller clusters to inherit the same delivery, networking, and secret patterns without requiring a separate platform model.
- Make it clear which documents describe patterns versus concrete `main` implementations.
