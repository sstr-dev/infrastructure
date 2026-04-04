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
function apply_helm_crds() {
    log debug "Applying CRDs"

    local -r helmfile_file="${ROOT_DIR}/bootstrap/${cluster}/helmfile.d/00-crds.yaml"

    if [[ ! -f "${helmfile_file}" ]]; then
        log error "File does not exist" "file=${helmfile_file}"
    fi

    if ! helmfile --kube-context ${cluster} --file "${helmfile_file}" template -q | yq ea -e 'select(.kind == "CustomResourceDefinition")' | kubectl --context ${cluster} apply --server-side --field-manager bootstrap --force-conflicts -f -; then
        log error "Failed to apply CRDs"
    fi

    log info "CRDs applied successfully"
}


function main() {
    check_env cluster
    check_cli helmfile jq kubectl kustomize minijinja-cli yq
    apply_helm_crds
    log info "Congrats! The cluster is bootstrapped and Flux is syncing the Git repository"
}

main "$@"
