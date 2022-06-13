#!/bin/bash
set -e
set -o nounset
set -o pipefail

fail() {
    printf "Missing parameter!\n" >2
    exit 1
}

kubectl_cmd() {
    if [[ "${EVENT_NAME}" == "presync" ]]; then
        printf "kubectl apply"
    elif [[ "${EVENT_NAME}" == "prepare" ]]; then
        printf "kubectl diff"
    else
        printf "kubectl apply"
    fi
}

bash_wrapper() {
    local script_path="${1}"
    local namespace="${2:-}"
    local suffix=""
    if [[ ! -z "${namespace}" ]]; then
        echo "Running '${script_path} ${namespace}'"
        bash -e "${script_path}" "${namespace}"
    else
        echo "Running '${script_path}'"
        bash -e "${script_path}"
    fi
}

kubectl_wrapper() {
    local yaml_path="${1}"
    local namespace="${2:-}"
    local kubectl_cmd="$(kubectl_cmd)"
    if [[ ! -z "${namespace}" ]]; then
        printf "Running '${kubectl_cmd} -n ${namespace} -f ${yaml_path}'"
        "${kubectl_cmd}" -n "${namespace}" -f "${yaml_path}"
    else
        printf "Running '${kubectl_cmd} -f ${yaml_path}'"
        "${kubectl_cmd}" -f "${yaml_path}"
    fi
}

kubectl_secrets_wrapper() {
    local yaml_path="${1}"
    local namespace="${2:-}"
    local kubectl_cmd="$(kubectl_cmd)"
    if [[ ! -z "${namespace}" ]]; then
        printf "Running 'sops -d ${yaml_path} | ${kubectl_cmd} -n ${namespace} -f -'"
        sops -d "${yaml_path}" | "${kubectl_cmd}" -n "${namespace}" -f -
    else
        printf "Running 'sops -d ${yaml_path} | ${kubectl_cmd} -f -'"
        sops -d "${yaml_path}" | "${kubectl_cmd}" -f -
    fi
}

export -f kubectl_cmd
export -f bash_wrapper
export -f kubectl_wrapper
export -f kubectl_secrets_wrapper

readonly EVENT_NAME="${1:-}"
readonly ENVIRONMENT_NAME="${2:-}"
readonly RELEASE_NAME="${3:-}"
readonly RELEASE_NAMESPACE="${4:-}"

[[ -z "${EVENT_NAME}" ]]        && fail
[[ -z "${ENVIRONMENT_NAME}" ]]  && fail
[[ -z "${EVENT_NAME}" ]]        && fail

if [[ "${EVENT_NAME}" == "presync" ]]; then
    readonly KUBECTL="kubectl apply"
    readonly YAML_SEARCH_SUFF="pre"
elif [[ "${EVENT_NAME}" == "prepare" ]]; then
    readonly KUBECTL="kubectl diff"
    readonly YAML_SEARCH_SUFF="pre"
else
    readonly KUBECTL="kubectl apply"
    readonly YAML_SEARCH_SUFF="post"
fi
readonly SH_SEARCH_SUFF="${EVENT_NAME}"

readonly CURRENT_PWD="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

if [[ ! -z "${RELEASE_NAME}" ]] && [[ ! -z "${RELEASE_NAMESPACE}" ]]; then
    readonly RELEASE_DIR="${CURRENT_PWD}/values/${RELEASE_NAME}"
    if [[ -d "${RELEASE_DIR}/raw" ]]; then
        find "${RELEASE_DIR}/raw" -name "*.common.${YAML_SEARCH_SUFF}.yaml" -exec bash -c 'kubectl_wrapper "$0" "$1"' {} "${RELEASE_NAMESPACE}" \;
        find "${RELEASE_DIR}/raw" -name "*.common.${YAML_SEARCH_SUFF}.secrets.yaml" -exec bash -c 'kubectl_secrets_wrapper "$0" "$1"' {} "${RELEASE_NAMESPACE}" \;
        find "${RELEASE_DIR}/raw" -name "*.${ENVIRONMENT_NAME}.${YAML_SEARCH_SUFF}.yaml" -exec bash -c 'kubectl_wrapper "$0" "$1"' {} "${RELEASE_NAMESPACE}" \;
        find "${RELEASE_DIR}/raw" -name "*.${ENVIRONMENT_NAME}.${YAML_SEARCH_SUFF}.secrets.yaml" -exec bash -c 'kubectl_secrets_wrapper "$0" "$1"' {} "${RELEASE_NAMESPACE}" \;
    fi

    if [[ -d "${RELEASE_DIR}/hooks" ]]; then
        find "${RELEASE_DIR}/hooks" -name "*.common.${SH_SEARCH_SUFF}.sh" -exec bash -c 'bash_wrapper "$0" "$1"' {} "${RELEASE_NAMESPACE}" \;
        find "${RELEASE_DIR}/hooks" -name "*.${ENVIRONMENT_NAME}.${SH_SEARCH_SUFF}.sh" -exec bash -c 'bash_wrapper "$0" "$1"' {} "${RELEASE_NAMESPACE}" \;
    fi
else
    if [[ -d "${CURRENT_PWD}/raw" ]]; then
        find "${CURRENT_PWD}/raw" -name "*.${YAML_SEARCH_SUFF}.yaml" -exec bash -c 'kubectl_wrapper "$0"' {} \;
        find "${CURRENT_PWD}/raw" -name "*.${YAML_SEARCH_SUFF}.secrets.yaml" -exec bash -c 'kubectl_secrets_wrapper "$0"' {} \;
    fi
    if [[ -d "${CURRENT_PWD}/hooks" ]]; then
        find "${CURRENT_PWD}/hooks" -name "*.${SH_SEARCH_SUFF}.sh" -exec bash -c 'bash_wrapper "$0"' {} \;
    fi
fi

