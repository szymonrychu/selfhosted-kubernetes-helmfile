#!/bin/bash
set -e
set -o nounset
set -o pipefail

readonly CURRENT_PWD="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

if [[ -z "${DEFAULT_TIMEOUT_S:-}" ]]; then
  readonly DEFAULT_TIMEOUT_S='600'
fi

fail() {
    local output="${1}"
    printf "%s\n" "${output}" >2
    exit 1
}

readonly PHASE="${1:-}"
readonly EVENT_NAME="${2:-}"
readonly RELEASE_NAME="${3:-}"
readonly RELEASE_NAMESPACE="${4:-}"
readonly TIMEOUT_S="${5:-$DEFAULT_TIMEOUT_S}"

[[ -z "${PHASE}" ]] && fail "Missing 1st parameter PHASE"
[[ -z "${EVENT_NAME}" ]] && fail "Missing 2nd parameter EVENT_NAME"

if [[ "${EVENT_NAME}" == "presync" ]]; then
    readonly KUBECTL="kubectl apply --wait=true"
    readonly YAML_SEARCH_SUFF="pre"
elif [[ "${EVENT_NAME}" == "prepare" ]]; then
    readonly KUBECTL="kubectl diff"
    readonly YAML_SEARCH_SUFF="pre"
elif [[ "${EVENT_NAME}" == "postsync" ]]; then
    readonly KUBECTL="kubectl apply --wait=true"
    readonly YAML_SEARCH_SUFF="post"
else
    fail "Not implemented event: '${EVENT_NAME}'"
fi

readonly TIMEOUT_TMSTP="$(($(date +%s) + TIMEOUT_S))"

if [[ ! -z "${RELEASE_NAME}" ]] && [[ ! -z "${RELEASE_NAMESPACE}" ]]; then

    if [[ "${EVENT_NAME}" == "presync" ]]; then
        printf "Checking '%s' helm relase health in '%s' namespace\n" "${RELEASE_NAME}" "${RELEASE_NAMESPACE}"

        faulty_release_revision=""
        while true; do
            faulty_release_revision="$(helm list --all-namespaces --output json | jq -r ".[] | select(.name==\"${RELEASE_NAME}\" and .namespace==\"${RELEASE_NAMESPACE}\" and .status != \"deployed\") | .revision")"
            if [[ -z "${faulty_release_revision}" ]]; then
                printf "Release ok!"
                break
            fi
            if [[ "$(date +%s)" -ge "${TIMEOUT_TMSTP}" ]]; then
                printf "Timeout waiting for release to stabilize reached, deleting secret '%s' in namespace '%s'!\n" "sh.helm.release.v1.${RELEASE_NAME}.v${faulty_release_revision}" "${RELEASE_NAMESPACE}"
                kubectl delete secret -n "${RELEASE_NAMESPACE}" "sh.helm.release.v1.${RELEASE_NAME}.v${faulty_release_revision}"
            fi
            sleep 1
        done
    fi

    readonly RELEASE_DIR="${CURRENT_PWD}/helmfiles/${PHASE}/values/${RELEASE_NAME}"
    if [[ -d "${RELEASE_DIR}/raw" ]]; then
        printf "Searching for files to apply for '%s' in '%s' namespace!\n" "${RELEASE_NAME}" "${RELEASE_NAMESPACE}"
        find "${RELEASE_DIR}/raw" -name "*.common.${YAML_SEARCH_SUFF}.yaml" -exec bash -xec "${KUBECTL} -n ${RELEASE_NAMESPACE} -f {}" \;
        find "${RELEASE_DIR}/raw" -name "*.common.${YAML_SEARCH_SUFF}.secrets.yaml" -exec bash -xec "sops -d {} | ${KUBECTL} -n ${RELEASE_NAMESPACE} -f -" \;
        find "${RELEASE_DIR}/raw" -name "*.${RELEASE_NAME}.${YAML_SEARCH_SUFF}.yaml" -exec bash -xec "${KUBECTL} -n ${RELEASE_NAMESPACE} -f {}" \;
        find "${RELEASE_DIR}/raw" -name "*.${RELEASE_NAME}.${YAML_SEARCH_SUFF}.secrets.yaml" -exec bash -xec "sops -d {} | ${KUBECTL} -n ${RELEASE_NAMESPACE} -f -" \;
    fi
else
    printf "Running hook for globally during '%s'\n" "${EVENT_NAME}"
    if [[ -d "${CURRENT_PWD}/raw" ]]; then
        printf "Searching for files to apply!\n"
        find "${CURRENT_PWD}/raw" -name "*.${YAML_SEARCH_SUFF}.yaml" -exec bash -xec "${KUBECTL} -n ${RELEASE_NAMESPACE} -f {}" \;
        find "${CURRENT_PWD}/raw" -name "*.${YAML_SEARCH_SUFF}.secrets.yaml" -exec bash -xec "sops -d {} | ${KUBECTL} -n ${RELEASE_NAMESPACE} -f -" \;
    fi
fi
