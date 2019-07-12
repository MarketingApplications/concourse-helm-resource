FROM linkyard/docker-helm:2.14.1
LABEL maintainer "mario.siegenthaler@linkyard.ch"

ENV CLOUD_SDK_VERSION 248.0.0
ENV KUBECTL_VERSION 1.14.2
ENV HELM_VERSION 2.11.1
ENV GOOGLE_APPLICATION_CREDENTIALS /root/gcloud-auth-key.json

ENV PATH /google-cloud-sdk/bin:$PATH

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
        && rm -rf /var/cache/apk/*

RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
        && tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
        && rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
        && ln -s /lib /lib64 \
        && gcloud config set core/disable_usage_reporting true \
        && gcloud config set component_manager/disable_update_check true \
        && gcloud --version \
        && gcloud components install alpha beta \
        && gcloud components update; \
        curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
        && chmod +x /usr/bin/kubectl

ADD assets /opt/resource
RUN chmod +x /opt/resource/*; \
        mkdir -p "$(helm home)/plugins"; \
        helm plugin install https://github.com/databus23/helm-diff \
        && helm plugin install https://github.com/rimusz/helm-tiller

ENTRYPOINT [ "/bin/bash" ]
