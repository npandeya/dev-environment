FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    python3 \
    python3-pip \
    ssh \
    jq \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/* && \
    curl -fsSL https://releases.hashicorp.com/terraform/1.5.5/terraform_1.5.5_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip -d /usr/local/bin \
    && rm terraform.zip \
    && pip3 install ansible \
    && mkdir -p /workspace/state /workspace/logs
WORKDIR /workspace
COPY . /workspace/
RUN chmod -R +x /workspace/scripts
CMD ["/workspace/scripts/run_all.sh"]
