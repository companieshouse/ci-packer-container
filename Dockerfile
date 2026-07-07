FROM 416670754337.dkr.ecr.eu-west-2.amazonaws.com/ci-core-runtime:1.1.0

ARG PACKER_VERSION=1.15.0
ARG PLATFORM_TOOLS_VERSION=1.0.6

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install essentials
RUN dnf update -y && \
    dnf install -y \
    dnf-utils-4.3.0 \
    git-2.50.1 \
    openssh-clients-8.7p1 \
    python3.12 \
    python3.12-pip \
    unzip-6.0 \
    wget-1.21.3 && \
    dnf clean all

# Install Ansible and required pip3.12 libraries
COPY resources/requirements.txt /requirements.txt
RUN python3.12 -m pip install --no-cache-dir -r /requirements.txt && \
    rm /requirements.txt

# Add platform-tools-common
RUN rpm --import http://yum-repository.platform.aws.chdev.org/RPM-GPG-KEY-platform-noarch && \
    yum-config-manager --add-repo http://yum-repository.platform.aws.chdev.org/platform-noarch.repo && \
    dnf install -y \
        "platform-tools-common-${PLATFORM_TOOLS_VERSION}" && \
    dnf clean all

# Install Packer
RUN curl -sL "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" -o "packer_${PACKER_VERSION}_linux_amd64.zip" && \
    curl -sL "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS" -o sha256sum.txt && \
    grep "packer_${PACKER_VERSION}_linux_amd64.zip" sha256sum.txt | sha256sum --check --status && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip -x LICENSE.txt -d /usr/bin/ && \
    chown root:root /usr/bin/packer && \
    chmod 755 /usr/bin/packer && \
    rm sha256sum.txt

# Create packer user
RUN useradd -ms /bin/bash packer
USER packer
