FROM linkyard/docker-helm:2.14.1 as docker-helm
LABEL maintainer "mario.siegenthaler@linkyard.ch"

FROM google/cloud-sdk:276.0.0-alpine

COPY --from=docker-helm /bin/helm /bin/helm

ENV KUBECTL_VERSION="1.14.2" \
    HELM_VERSION="2.14.1" \
    SOPS_VERSION="3.3.1" \
    HELM_GCS_VERSION="0.2.1" \
    GOOGLE_APPLICATION_CREDENTIALS="/root/gcloud-auth-key.json"

ADD assets /opt/resource

RUN apk --no-cache add \
        curl \
        python \
        py-crcmod \
        bash \
        libc6-compat \
        git \
        openssl \
        tar \
        jq \
        ca-certificates \
        && rm -rf /var/cache/apk/*; \
    curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
        && chmod +x /usr/bin/kubectl; \
    chmod +x /opt/resource/*; \
        mkdir -p "$(helm home)/plugins"; \
        helm plugin install https://github.com/databus23/helm-diff \
        && helm plugin install https://github.com/rimusz/helm-tiller \
        && helm plugin install https://github.com/futuresimple/helm-secrets --version 2.0.2 \
        && helm plugin install https://github.com/hayorov/helm-gcs --version 0.2.1; \
        curl -s -L -o /usr/local/bin/sops https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux \
        && chmod +x /usr/local/bin/sops

ENTRYPOINT [ "/bin/bash" ]
