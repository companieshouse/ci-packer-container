FROM 416670754337.dkr.ecr.eu-west-2.amazonaws.com/ci-core-runtime:1.1.0

# Install essentials
RUN dnf update -y && \
    dnf install -y \
    git \
    openssh-clients \
    python3.12 \
    python3.12-pip \
    unzip \
    wget && \
    dnf clean all

# Install Ansible and required pip3.12 libraries
COPY resources/requirements.txt /requirements.txt
RUN python3.12 -m pip install --no-cache-dir -r /requirements.txt && \
    rm /requirements.txt

# Install Packer
RUN curl -sL "https://releases.hashicorp.com/packer/1.15.0/packer_1.15.0_linux_amd64.zip" -o "packer_1.15.0_linux_amd64.zip" && \
    curl -sL "https://releases.hashicorp.com/packer/1.15.0/packer_1.15.0_SHA256SUMS" -o sha256sum.txt && \
    grep "packer_1.15.0_linux_amd64.zip" sha256sum.txt | sha256sum --check --status && \
    unzip packer_1.15.0_linux_amd64.zip -x LICENSE.txt -d /usr/bin/ && \
    chown root:root /usr/bin/packer && \
    chmod 755 /usr/bin/packer && \
    rm sha256sum.txt

# Create packer user
RUN useradd -ms /bin/bash packer
USER packer
