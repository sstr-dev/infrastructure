#!/usr/bin/env bash
set -Eeuo pipefail

export ROOT_DIR
ROOT_DIR="$(git rev-parse --show-toplevel)"

readonly CLUSTER="${1:?missing cluster argument}"
readonly TALOS_DIR="${ROOT_DIR}/talos/${CLUSTER}"
readonly TALOSCONFIG_FILE="${TALOSCONFIG:-${TALOS_DIR}/talosconfig}"
readonly MACHINECONFIG_FILE="${TALOS_DIR}/machineconfig.yaml.j2"
readonly NODES_DIR="${TALOS_DIR}/nodes"
readonly KUBECONFIG_DIR="${ROOT_DIR}/kubernetes/clusters/${CLUSTER}"

# Log messages with structured output
function log() {
    local lvl="${1:?}" msg="${2:?}"
    shift 2
    gum log --time=rfc3339 --structured --level "${lvl}" "[${FUNCNAME[1]}] ${msg}" "$@"
}

function die() {
    local msg="${1:?}"
    shift || true
    log fatal "${msg}" "$@"
    exit 1
}

function require_cmds() {
    local cmd
    for cmd in gum talosctl yq bash; do
        command -v "${cmd}" >/dev/null 2>&1 || die "Missing required command" "command" "${cmd}"
    done
}

function ensure_files() {
    [[ -f "${MACHINECONFIG_FILE}" ]] || die "Machine config template not found" "file" "${MACHINECONFIG_FILE}"
    [[ -d "${NODES_DIR}" ]] || die "Nodes directory not found" "dir" "${NODES_DIR}"
    [[ -f "${TALOSCONFIG_FILE}" ]] || die "Talos config not found" "file" "${TALOSCONFIG_FILE}"
}

function get_nodes() {
    local nodes
    if ! nodes="$(talosctl --talosconfig "${TALOSCONFIG_FILE}" config info --output yaml | yq --exit-status '.nodes | join(" ")')"; then
        die "Failed to read nodes from talosconfig" "talosconfig" "${TALOSCONFIG_FILE}"
    fi
    [[ -n "${nodes}" ]] || die "No nodes found in talosconfig" "talosconfig" "${TALOSCONFIG_FILE}"
    printf '%s\n' "${nodes}"
}

function get_controller() {
    local controller
    if ! controller="$(talosctl --talosconfig "${TALOSCONFIG_FILE}" config info --output yaml | yq --exit-status '.endpoints[0]')"; then
        die "Failed to read first controller endpoint from talosconfig" "talosconfig" "${TALOSCONFIG_FILE}"
    fi
    [[ -n "${controller}" ]] || die "No controller endpoint found in talosconfig" "talosconfig" "${TALOSCONFIG_FILE}"
    printf '%s\n' "${controller}"
}

# Apply the Talos configuration to all nodes listed in talosconfig.
function install_talos() {
    log info "Installing Talos configuration" "cluster" "${CLUSTER}"

    local nodes node node_file machine_config output
    nodes="$(get_nodes)"

    for node in ${nodes}; do
        node_file="${NODES_DIR}/${node}.yaml.j2"
        [[ -f "${node_file}" ]] || die "Node template not found" "node" "${node}" "file" "${node_file}"
    done

    for node in ${nodes}; do
        node_file="${NODES_DIR}/${node}.yaml.j2"
        log info "Applying Talos machine config" "node" "${node}" "template" "${node_file}"

        if ! machine_config="$(bash "${ROOT_DIR}/scripts/render-machine-config.sh" "${MACHINECONFIG_FILE}" "${node_file}")" || [[ -z "${machine_config}" ]]; then
            die "Failed to render Talos machine config" "node" "${node}" "template" "${node_file}"
        fi

        # Try secure apply first. If that fails due auth/trust, fall back to --insecure
        # for nodes in maintenance mode.
        if output="$(printf '%s' "${machine_config}" | talosctl --talosconfig "${TALOSCONFIG_FILE}" --nodes "${node}" apply-config --mode auto --file /dev/stdin 2>&1)"; then
            log info "Applied Talos machine config (secure)" "node" "${node}"
            continue
        fi

        log warn "Secure apply failed, trying insecure apply" "node" "${node}" "error" "${output}"

        if output="$(printf '%s' "${machine_config}" | talosctl --talosconfig "${TALOSCONFIG_FILE}" --nodes "${node}" apply-config --mode auto --insecure --file /dev/stdin 2>&1)"; then
            log info "Applied Talos machine config (insecure)" "node" "${node}"
            continue
        fi

        die "Failed to apply Talos machine config" "node" "${node}" "error" "${output}"
    done
}

# Bootstrap Talos on the first controller endpoint.
function install_kubernetes() {
    log info "Bootstrapping Talos/Kubernetes"

    local controller output max_attempts attempt
    controller="$(get_controller)"
    max_attempts=60

    for attempt in $(seq 1 "${max_attempts}"); do
        if output="$(talosctl --talosconfig "${TALOSCONFIG_FILE}" --nodes "${controller}" bootstrap 2>&1)"; then
            log info "Talos bootstrap succeeded" "controller" "${controller}" "attempt" "${attempt}"
            return 0
        fi

        if [[ "${output}" == *"AlreadyExists"* ]]; then
            log info "Talos bootstrap already completed" "controller" "${controller}" "attempt" "${attempt}"
            return 0
        fi

        # Fast-fail on known trust/auth mismatch.
        if [[ "${output}" == *"certificate signed by unknown authority"* || "${output}" == *"authentication handshake failed"* ]]; then
            die "Talos bootstrap failed due to TLS trust mismatch" "controller" "${controller}" "error" "${output}"
        fi

        log warn "Talos bootstrap not ready yet, retrying in 5s" "controller" "${controller}" "attempt" "${attempt}" "error" "${output}"
        sleep 5
    done

    die "Talos bootstrap timed out" "controller" "${controller}" "max_attempts" "${max_attempts}"
}

function fetch_kubeconfig() {
    log info "Fetching kubeconfig"

    local controller
    controller="$(get_controller)"
    mkdir -p "${KUBECONFIG_DIR}"

    if ! talosctl --talosconfig "${TALOSCONFIG_FILE}" kubeconfig --nodes "${controller}" --force --force-context-name "${CLUSTER}" "${KUBECONFIG_DIR}" &>/dev/null; then
        die "Failed to fetch kubeconfig" "controller" "${controller}" "output_dir" "${KUBECONFIG_DIR}"
    fi

    log info "Kubeconfig fetched successfully" "output_dir" "${KUBECONFIG_DIR}"
}

function main() {
    require_cmds
    ensure_files
    install_talos
    install_kubernetes
    fetch_kubeconfig
}

main "$@"
