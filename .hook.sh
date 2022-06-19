#!/bin/bash
set -e
set -o nounset
set -o pipefail

if [[ -z "${DEFAULT_TIMEOUT_S:-}" ]]; then
  readonly DEFAULT_TIMEOUT_S='600'
fi

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

fixHelmRelease() {
    local release="$1"
    local namespace="$2"
    kubectl delete secret \
        -n "${namespace}" \
        "$(kubectl get secrets -n "${namespace}" | grep -E "^sh.helm.release.v1.${release}.v[0-9]+" | awk '{print $1}' | tail -1)"
}

timeoutReached() {
  local end_time="$1"
  if [[ "$(date +%s)" -ge "${end_time}" ]]; then
    printf "Timeout reached, removing locks!\n" >&2
    for helm_release_namespace in $(helm list --all-namespaces --failed --pending --output json | jq -r '.[] | .name + ":" + .namespace'); do
        helm_release="$(printf "${helm_release_namespace}" | cut -d':' -f1)"
        helm_namespace="$(printf "${helm_release_namespace}" | cut -d':' -f2)"
        fixHelmRelease "${helm_release}" "${helm_namespace}"
    done
    exit
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
readonly TIMEOUT_S="${5:-$DEFAULT_TIMEOUT_S}"

[[ -z "${EVENT_NAME}" ]]        && fail
[[ -z "${ENVIRONMENT_NAME}" ]]  && fail
[[ -z "${EVENT_NAME}" ]]        && fail

readonly TIMEOUT_TMSTP="$(($(date +%s) + TIMEOUT_S))"

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

printf ""
while [[ $(helm list --all-namespaces --failed --pending --output json | jq '. | length') -gt 0 ]]; do
    timeoutReached "${TIMEOUT_TMSTP}"
    printf "."
    sleep 1
done

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

