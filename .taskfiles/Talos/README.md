# Talos Taskfile

This Taskfile groups the most common operational Talos workflows for a cluster.
It is included in the root `Taskfile.yaml` under the `talos` namespace:

```bash
task talos:<task> cluster=main
```

By default, `cluster=main` is used unless another cluster is provided.

## Requirements

Most tasks expect:

- `talosctl` in `PATH`
- a valid Talos configuration at `talos/<cluster>/talosconfig`
- cluster-specific templates under `talos/<cluster>/`
- depending on the task, also `jq`, `yq`, `vault`, `gum`, or `minijinja-cli`

Important paths:

- `talos/<cluster>/machineconfig.yaml.j2`
- `talos/<cluster>/nodes/*.yaml.j2`
- `talos/<cluster>/schematic.yaml`
- `scripts/render-machine-config.sh`

## Common Tasks

### Bootstrap

Bootstrap a Talos cluster:

```bash
task talos:bootstrap cluster=main
```

After that, bootstrap the cluster apps:

```bash
task talos:apps cluster=main
```

### Apply Configuration

Apply configuration to a single node:

```bash
task talos:apply-node cluster=main node=cp01.k8s.main.internal
```

Optionally, set a Talos apply mode:

```bash
task talos:apply-node cluster=main node=cp01.k8s.main.internal MODE=reboot
```

Apply configuration to all nodes from `talosconfig`:

```bash
task talos:apply-cluster cluster=main
```

### Generate Kubeconfig

Regenerate the kubeconfig for the cluster:

```bash
task talos:kubeconfig cluster=main
```

### Reboot and Reset

Reboot a single node:

```bash
task talos:reboot-node cluster=main node=wk01.k8s.main.internal
```

Use a different reboot mode:

```bash
task talos:reboot-node cluster=main node=wk01.k8s.main.internal MODE=soft
```

Reboot the whole cluster:

```bash
task talos:reboot-cluster cluster=main
```

Reset a single node completely:

```bash
task talos:reset-node cluster=main node=wk01.k8s.main.internal
```

Reset the whole cluster:

```bash
task talos:reset-cluster cluster=main
```

`reset-node` and `reset-cluster` are destructive and wipe Talos system data.

## Diagnostics and Operations

Show the disks for a node:

```bash
task talos:disks cluster=main node=wk01.k8s.main.internal
```

Inspect Talos volumes:

```bash
task talos:volumestatus cluster=main node=wk01.k8s.main.internal
```

Show mounts:

```bash
task talos:mounts cluster=main node=wk01.k8s.main.internal
```

Check usage for the extra mount:

```bash
task talos:usage-extra cluster=main node=wk01.k8s.main.internal
```

Open the Talos dashboard:

```bash
task talos:dashboard cluster=main
```

## Rendering and Templates

Render the MachineConfig for a node as a test:

```bash
task talos:test-render cluster=main node=cp01.k8s.main.internal
```

The output is written to `talos/<cluster>/test.yaml`.

## ISO and Schematic

Generate a schematic ID from `talos/<cluster>/schematic.yaml`:

```bash
task talos:generate-schematic cluster=main
```

Generate the download URL for a Talos ISO:

```bash
task talos:generate-iso-url version=v1.11.2
```

Download the ISO:

```bash
task talos:generate-iso cluster=main version=v1.11.2
```

## Common Workflows

### Change Node Configuration

```bash
task talos:apply-node cluster=main node=cp01.k8s.main.internal
```

### Roll Out Cluster Configuration

```bash
task talos:apply-cluster cluster=main
task talos:kubeconfig cluster=main
```

### Check After a Disk Resize

```bash
task talos:disks cluster=main node=wk01.k8s.main.internal
task talos:volumestatus cluster=main node=wk01.k8s.main.internal
task talos:mounts cluster=main node=wk01.k8s.main.internal
```

If the physical disk is larger but `EPHEMERAL` did not grow, rebooting the node often resolves it.
