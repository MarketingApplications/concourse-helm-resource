FROM google/cloud-sdk:315.0.0-alpine

ENV KUBECTL_VERSION="1.17.12" \
    HELM_VERSION="2.16.12" \
    SOPS_VERSION="3.6.1" \
    HELM_GCS_VERSION="0.2.2" \
    HELM_DIFF_VERSION="3.1.3" \
    HELM_TILLER_VERSION="0.9.3" \
    HELM_SECRETS_VERSION="2.0.2" \
    GOOGLE_APPLICATION_CREDENTIALS="/root/gcloud-auth-key.json"

ADD assets /opt/resource

RUN set -exu && \
    apk --no-cache add \
        curl \
        bash \
        git \
        openssl \
        tar \
        jq \
        ca-certificates \
        && rm -rf /var/cache/apk/* \
    && curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
        && chmod +x /usr/bin/kubectl \
        && chmod +x /opt/resource/* \
    && curl -L -O https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
        && curl -L -O https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz.sha256 \
        && sed -i "s/\$/  helm-v${HELM_VERSION}-linux-amd64.tar.gz/g" helm-v${HELM_VERSION}-linux-amd64.tar.gz.sha256 \
        && sha256sum -c helm-v${HELM_VERSION}-linux-amd64.tar.gz.sha256 \
        && rm helm-v${HELM_VERSION}-linux-amd64.tar.gz.sha256 \
        && tar zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
        && mv linux-amd64/helm /bin/helm \
        && chmod +x /bin/helm \
        && rm helm-v${HELM_VERSION}-linux-amd64.tar.gz \
        && rm -rf linux-amd64 \
        && mkdir -p "$(helm home)/plugins" \
    && helm plugin install https://github.com/databus23/helm-diff --version ${HELM_DIFF_VERSION} \
        && helm plugin install https://github.com/rimusz/helm-tiller --version ${HELM_TILLER_VERSION} \
        && helm plugin install https://github.com/zendesk/helm-secrets --version ${HELM_SECRETS_VERSION} \
        && helm plugin install https://github.com/hayorov/helm-gcs --version ${HELM_GCS_VERSION} \
    && curl -L -o /usr/local/bin/sops https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux \
        && chmod +x /usr/local/bin/sops

ENTRYPOINT [ "/bin/bash" ]
