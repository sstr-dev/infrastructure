#!/usr/bin/env bash
set -Eeuo pipefail

source "$(dirname "${0}")/lib/common.sh"

export LOG_LEVEL="debug"
export ROOT_DIR="$(git rev-parse --show-toplevel)"

# Talos requires the nodes to be 'Ready=False' before applying resources
function wait_for_nodes() {
    log debug "Waiting for nodes to be available"

    # Skip waiting if all nodes are 'Ready=True'
    if kubectl --context ${cluster}  wait nodes --for=condition=Ready=True --all --timeout=10s &>/dev/null; then
        log info "Nodes are available and ready, skipping wait for nodes"
        return
    fi

    # Wait for all nodes to be 'Ready=False'
    until kubectl --context ${cluster} wait nodes --for=condition=Ready=False --all --timeout=10s &>/dev/null; do
        log info "Nodes are not available, waiting for nodes to be available. Retrying in 10 seconds..."
        sleep 10
    done
}

# CRDs to be applied before the helmfile charts are installed
function apply_crds() {
    log debug "Applying CRDs"

    local -r crds=(
        # renovate: datasource=github-releases depName=kubernetes-sigs/gateway-api
        # https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/experimental-install.yaml
        # renovate: datasource=github-releases depName=prometheus-operator/prometheus-operator
        https://github.com/prometheus-operator/prometheus-operator/releases/download/v0.84.0/stripped-down-crds.yaml
        # renovate: datasource=github-releases depName=kubernetes-sigs/external-dns
        # https://raw.githubusercontent.com/kubernetes-sigs/external-dns/refs/tags/v0.18.0/docs/sources/crd/crd-manifest.yaml
    )

    for crd in "${crds[@]}"; do
        if kubectl --context ${cluster} diff --filename "${crd}" &>/dev/null; then
            log info "CRDs are up-to-date" "crd=${crd}"
            continue
        fi
        # kubectl --context ${cluster} apply --server-side --filename "${crd}" --force-conflicts
        if kubectl --context ${cluster} apply --server-side --filename "${crd}" &>/dev/null; then
            log info "CRDs applied" "crd=${crd}"
        else
            log error "Failed to apply CRDs" "crd=${crd}"
        fi
    done
}

function apply_secrets() {

    local -r cluster_secrets=(
        github-ssh-secret.sops.yaml
        vault-cluster-creds.sops.yaml
    )
    local -r flux_secrets=(
        "${components_dir}/common/sops/secret.sops.yaml"
    )
    for secret in "${cluster_secrets[@]}"; do
        if [[ -f "${cluster_dir}/bootstrap/${secret}" ]]; then
            if sops --decrypt ${cluster_dir}/bootstrap/${secret} | kubectl apply --context ${cluster} --server-side --filename - &>/dev/null; then
                log info "secret applied" "secret=${secret}"
            else
                log error "Failed to apply secret" "secret=${secret}"
            fi
        else
            log info "File does not exist" "file=${cluster_dir}/bootstrap/${secret}"
        fi
    done
    for secret in "${flux_secrets[@]}"; do
        # enforce
        if sops --decrypt ${secret} | kubectl apply --context ${cluster} --namespace flux-system --force-conflicts --server-side --filename - &>/dev/null; then
            log info "secret applied" "secret=${secret}"
        else
            log error "Failed to apply secret" "secret=${secret}"
        fi
    done
}

# Resources to be applied before the helmfile charts are installed
function apply_resources() {
    log debug "Applying resources"

    local -r resources_file="${ROOT_DIR}/bootstrap/resources.yaml.j2"

    if ! output=$(render_template "${resources_file}") || [[ -z "${output}" ]]; then
        exit 1
    fi

    if echo "${output}" | kubectl --context ${cluster} diff --filename - &>/dev/null; then
        log info "Resources are up-to-date"
        return
    fi

    if echo "${output}" | kubectl --context ${cluster} apply --server-side --filename - &>/dev/null; then
        log info "Resources applied"
    else
        log error "Failed to apply resources"
    fi
}

# Apply Helm releases using helmfile
function apply_helm_releases() {
    log debug "Applying Helm releases with helmfile"

    local -r helmfile_file="${ROOT_DIR}/bootstrap/helmfile.yaml"

    if [[ ! -f "${helmfile_file}" ]]; then
        log error "File does not exist" "file=${helmfile_file}"
    fi

    if ! helmfile --kube-context ${cluster} --file "${helmfile_file}" apply --hide-notes --skip-diff-on-install --suppress-diff --suppress-secrets; then
        log error "Failed to apply Helm releases"
    fi

    log info "Helm releases applied successfully"
}

function main() {
    check_env cluster
    check_cli helmfile jq kubectl kustomize minijinja-cli yq

    # Apply resources and Helm releases
    wait_for_nodes
    apply_crds
    apply_resources
    apply_secrets
    apply_helm_releases

    log info "Congrats! The cluster is bootstrapped and Flux is syncing the Git repository"
}

main "$@"
