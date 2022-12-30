FROM amazonlinux:2

ARG PACKER_VERSION=1.6.6

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN amazon-linux-extras enable python3.8 && \
    yum clean metadata && \
    yum install -y \
    openssh-clients \
    git \
    wget \
    bsdtar \
    python38 && \
    yum clean all

# Remove conflicting cracklib-packer symlink
RUN unlink /usr/sbin/packer

COPY resources/requirements.txt /requirements.txt
RUN python3.8 -m pip install --no-cache-dir -r /requirements.txt && \
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
