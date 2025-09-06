FROM alpine:3.20

# Install dependencies
RUN apk add --no-cache \
    curl \
    unzip \
    bash \
    ca-certificates \
    python3 \
    py3-pip \
    jq

# Install AWS CLI via apk (simplest approach)
RUN apk add --no-cache aws-cli

# Install Node.js 20 (LTS) and npm
RUN apk add --no-cache nodejs-lts npm

# Install Terraform
ARG TERRAFORM_VERSION=1.13.1
RUN ARCH=$(uname -m) \
    && if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; fi \
    && if [ "$ARCH" = "aarch64" ]; then ARCH="arm64"; fi \
    && curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip

# Create non-root user
RUN addgroup -g 1000 terraform \
    && adduser -D -u 1000 -G terraform terraform

USER terraform
WORKDIR /workspace

# Verify installations
RUN terraform --version && aws --version && jq --version && node --version && npm --version

CMD ["/bin/bash"]