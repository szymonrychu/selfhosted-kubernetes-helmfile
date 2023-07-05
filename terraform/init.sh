#!/bin/bash
readonly KEYCLOAK_PROVIDER_VERSION="4.3.1"


readonly SYSTEM="$(uname -s | tr '[:upper:]' '[:lower:]')"
readonly ARCH="$(uname -m)"
readonly PROVIDER_URL="https://github.com/mrparkers/terraform-provider-keycloak/releases/download/v${KEYCLOAK_PROVIDER_VERSION}/terraform-provider-keycloak_${KEYCLOAK_PROVIDER_VERSION}_${SYSTEM}_${ARCH}.zip"
readonly TMPDIR="/tmp/init-keycloak-provider"


rm -rf "${TMPDIR}"
mkdir -p "${TMPDIR}"
cd "${TMPDIR}"

curl -o "${TMPDIR}/keycloak-provider.zip" -LJO "${PROVIDER_URL}"
unzip "${TMPDIR}/keycloak-provider.zip"

mkdir -p "~/.terraform.d/plugins/mrparkers/keycloak/${KEYCLOAK_PROVIDER_VERSION}/"
mv "${TMPDIR}/terraform-provider-keycloak_v${KEYCLOAK_PROVIDER_VERSION}" "~/.terraform.d/plugins/mrparkers/keycloak/${KEYCLOAK_PROVIDER_VERSION}/${SYSTEM}_${ARCH}"

