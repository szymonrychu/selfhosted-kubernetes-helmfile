FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN set -xe;\
    apt-get update;\
    apt-get install --no-install-recommends -y \
        software-properties-common \
        apt-transport-https \
        bash \
        curl \
        wget \
        gnupg \
        python3-pip \
        zip \
        unzip \
        tar \
        git \
    ;\
    pip3 install --upgrade pip

ENV SOPS_VERSION=3.7.3 \
    SOPS_SHA256="53aec65e45f62a769ff24b7e5384f0c82d62668dd96ed56685f649da114b4dbb" \
    \
    KUBECTL_VERSION=1.25.0 \
    KUBECTL_SHA256="e23cc7092218c95c22d8ee36fb9499194a36ac5b5349ca476886b7edc0203885" \
    \
    TERRAFORM_VERSION=1.1.7 \
    TERRAFORM_SHA256="e4add092a54ff6febd3325d1e0c109c9e590dc6c38f8bb7f9632e4e6bcca99d4" \
    \
    YQ_VERSION=4.12.1 \
    YQ_SHA256="9fb9f92dd10899467d5e966b86c3cd981b1664ece9d8d61c13f16958bd1ac586" \
    \
    HELM_VERSION=3.9.4 \
    HELM_SHA256="31960ff2f76a7379d9bac526ddf889fb79241191f1dbe2a24f7864ddcb3f6560" \
    \
    HELMFILE_VERSION=0.148.1 \
    HELMFILE_SHA256="97b5ed8f3a4c1d5202770110852eb96843656a0d260a4c5b079209dc3a71dc7f"

RUN set -xe;\
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -;\
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable";\
    apt-get update;\
    apt-get install -y --no-install-recommends docker-ce-cli

RUN set -xe;\
    curl -sLo /tmp/sops https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux;\
    echo "${SOPS_SHA256}  /tmp/sops" | sha256sum -c || (sha256sum /tmp/sops; exit 1);\
    chmod +x /tmp/sops;\
    mv /tmp/sops /usr/bin/sops

RUN set -xe;\
    curl -sLo /tmp/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl;\
    echo "${KUBECTL_SHA256}  /tmp/kubectl" | sha256sum -c || (sha256sum /tmp/kubectl; exit 1);\
    chmod +x /tmp/kubectl;\
    mv /tmp/kubectl /usr/bin/kubectl

RUN set -xe;\
    curl -sLo /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip;\
    echo "${TERRAFORM_SHA256}  /tmp/terraform.zip" | sha256sum -c || (sha256sum /tmp/terraform.zip; exit 1);\
    unzip /tmp/terraform.zip;\
    mv terraform /usr/bin/terraform;\
    rm /tmp/terraform.zip


RUN set -xe;\
    curl -sLo /tmp/yq https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64;\
    echo "${YQ_SHA256}  /tmp/yq" | sha256sum -c || (sha256sum /tmp/yq; exit 1);\
    chmod +x /tmp/yq;\
    mv /tmp/yq /usr/bin/yq

RUN set -xe;\
    curl -sLo /tmp/helm.tgz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz;\
    echo "${HELM_SHA256}  /tmp/helm.tgz" | sha256sum -c || (sha256sum /tmp/helm.tgz; exit 1);\
    tar -xzf /tmp/helm.tgz;\
    mv linux-amd64/helm /usr/bin/helm;\
    helm plugin install https://github.com/jkroepke/helm-secrets --version v3.9.1;\
    helm plugin install https://github.com/databus23/helm-diff --version v3.1.3;\
    helm plugin install https://github.com/chartmuseum/helm-push --version v0.10.2;\
    rm /tmp/helm.tgz

RUN set -xe;\
    curl -sLo /tmp/helmfile.tgz https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz ;\
    echo "${HELMFILE_SHA256}  /tmp/helmfile.tgz" | sha256sum -c || (sha256sum /tmp/helmfile.tgz; exit 1);\
    tar -xzf /tmp/helmfile.tgz;\
    mv helmfile /usr/bin/helmfile

RUN rm -rf /tmp/*;\
    unset \
        "SOPS_VERSION" \
        "SOPS_SHA" \
        "KUBECTL_VERSION" \
        "KUBECTL_SHA" \
        "TERRAFORM_VERSION" \
        "TERRAFORM_SHA" \
        "YQ_VERSION" \
        "YQ_SHA" \
        "HELM_VERSION" \
        "HELM_SHA" \
        "HELMFILE_VERSION" \
        "HELMFILE_SHA"