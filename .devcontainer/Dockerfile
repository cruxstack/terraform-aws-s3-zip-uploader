FROM mcr.microsoft.com/vscode/devcontainers/base:1-focal

# install aws
RUN apt-get update && \
    apt-get install -y unzip python3-pip && \
    pip3 install --no-cache-dir --upgrade awscli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install terraform
ENV TERRAFORM_VERSION=1.5.1
ENV TF_PLUGIN_CACHE_DIR=$HOME/.terraform.d/plugin-cache
RUN mkdir -p $TF_PLUGIN_CACHE_DIR
RUN SYSTEM_ARCH=$(dpkg --print-architecture) \
    && curl -OL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${SYSTEM_ARCH}.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_${SYSTEM_ARCH}.zip \
    && mv terraform /usr/local/bin/ \
    && terraform version \
    && rm terraform_${TERRAFORM_VERSION}_linux_${SYSTEM_ARCH}.zip

# install docker
COPY --from=docker:dind /usr/local/bin/docker /usr/local/bin/

# install python packages
RUN python3 -m pip install \
    boto3 \
    black

# verify installs
RUN terraform --version \
    && aws --version \
    && docker --version
