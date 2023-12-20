FROM 416670754337.dkr.ecr.eu-west-2.amazonaws.com/ci-core-runtime:latest

ARG PACKER_VERSION=1.10.0

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN    dnf clean metadata && \
    dnf update -y && \
    dnf install -y \
    openssh-clients \
    git \
    pip \
    wget \
    bsdtar && \
    dnf clean all

COPY resources/requirements.txt /requirements.txt
 RUN python3 -m pip install --no-cache-dir -r /requirements.txt && \
     rm /requirements.txt

RUN rpm --import http://yum-repository.platform.aws.chdev.org/RPM-GPG-KEY-platform-noarch && \
    yum install -y yum-utils && \
    yum-config-manager --add-repo http://yum-repository.platform.aws.chdev.org/platform-noarch.repo && \
    yum install -y platform-tools-common && \
    yum clean all

# Install Packer
RUN wget -qO- https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip | bsdtar -xvf- -C /usr/bin/ && \
    chown root:root /usr/bin/packer && \
    chmod 755 /usr/bin/packer

# Create packer user
RUN useradd -ms /bin/bash packer
USER packer

WORKDIR /playbook

ENTRYPOINT ["/bin/bash"]
