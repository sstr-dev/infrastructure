#!/usr/bin/env python3
"""Update local Talos template image tags after a successful cluster upgrade."""

import argparse
import json
from pathlib import Path
import re
import subprocess


def version(value):
    if not re.fullmatch(r"v?\d+\.\d+\.\d+", value):
        raise argparse.ArgumentTypeError("Expected a stable version, e.g. v1.37.1")
    return "v" + value.removeprefix("v")


def cluster_versions(kubeconfig):
    def read(*arguments):
        result = subprocess.run(
            ["kubectl", "--kubeconfig", str(kubeconfig), "--request-timeout=20s", *arguments, "-o", "json"],
            check=True, capture_output=True, text=True, timeout=60,
        )
        return json.loads(result.stdout)

    nodes = read("get", "nodes")["items"]
    if not nodes:
        raise ValueError("Cluster has no nodes")
    talos_versions = set()
    kubernetes_versions = set()
    for node in nodes:
        info = node["status"]["nodeInfo"]
        match = re.fullmatch(r"Talos \((v?\d+\.\d+\.\d+)\)", info["osImage"])
        if not match:
            raise ValueError(f"Unrecognized Talos version on {node['metadata']['name']}")
        talos_versions.add(version(match[1]))
        kubernetes_versions.add(version(info["kubeletVersion"]))
    kubernetes_versions.add(version(read("version")["serverVersion"]["gitVersion"]))
    if len(talos_versions) != 1 or len(kubernetes_versions) != 1:
        raise ValueError("Cluster versions differ across nodes/API server; finish the upgrade first")
    return talos_versions.pop(), kubernetes_versions.pop()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("cluster", choices=("main", "test", "registry"))
    parser.add_argument("--kubernetes", type=version)
    parser.add_argument("--talos", type=version)
    parser.add_argument("--from-cluster", action="store_true", help="Read Talos and Kubernetes versions from the cluster")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    if args.from_cluster:
        if args.kubernetes or args.talos:
            parser.error("--from-cluster cannot be combined with explicit versions")
        try:
            args.talos, args.kubernetes = cluster_versions(root / "kubernetes" / "clusters" / args.cluster / "kubeconfig")
        except (OSError, subprocess.SubprocessError, ValueError, KeyError, argparse.ArgumentTypeError) as error:
            parser.error(f"Cannot read cluster versions: {error}")
        print(f"{args.cluster}: Talos {args.talos}, Kubernetes {args.kubernetes}")
    elif not (args.kubernetes or args.talos):
        parser.error("Specify --from-cluster or --kubernetes and/or --talos")

    path = root / "talos" / args.cluster / "machineconfig.yaml.j2"
    original = path.read_text()
    updated = original
    images = []
    if args.kubernetes:
        images.extend((image, args.kubernetes) for image in (
            "ghcr.io/siderolabs/kubelet",
            "registry.k8s.io/kube-apiserver",
            "registry.k8s.io/kube-controller-manager",
            "registry.k8s.io/kube-proxy",
            "registry.k8s.io/kube-scheduler",
        ))
    if args.talos:
        installers = re.findall(r"^\s*image: (factory\.talos\.dev/metal-installer/[a-f0-9]+):", original, re.MULTILINE)
        if len(installers) != 1:
            parser.error("Expected exactly one Talos factory installer image; template unchanged")
        images.append((installers[0], args.talos))

    for image, target in images:
        pattern = rf"^(\s*image: {re.escape(image)}:)v?\d+\.\d+\.\d+([ \t]*(?:#.*)?)$"
        updated, count = re.subn(pattern, lambda match: match[1] + target + match[2], updated, flags=re.MULTILINE)
        if count != 1:
            parser.error(f"Expected exactly one stable tag for {image}; template unchanged")

    if updated == original:
        print(f"Already up to date: {path}")
    elif args.dry_run:
        print(f"Would update: {path}")
    else:
        path.write_text(updated)
        print(f"Updated: {path}")


if __name__ == "__main__":
    main()
