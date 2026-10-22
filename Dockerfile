# hadolint global ignore=DL3041
FROM amazonlinux:2023

ARG PACKER_VERSION=1.10.0

# Deny use of the compromised eMudhra intermediate CA certificates.
# The AL2023 distro is already distrusting the intermediate CA, but
# still trusts the root cert.  This blacklists the required roots.
# Taken from https://emudhra.we-have-a-problem.com/
RUN d=/etc/pki/ca-trust/source/blocklist; \
    if [ ! -d "$d" ]; then d=/etc/pki/ca-trust/source/blacklist; fi && \
    trust extract --overwrite --format=pem-bundle \
    --filter='pkcs11:object=Comodo%20AAA%20Services%20root;type=cert' \
    "$d/Comodo_AAA_Services_root.pem" && \
    trust extract --overwrite --format=pem-bundle \
    --filter='pkcs11:object=emSign%20ECC%20Root%20CA%20-%20G3;type=cert' \
    "$d/emSign_ECC_Root_CA_-_G3.pem" && \
    update-ca-trust

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN dnf clean metadata && \
    dnf update -y && \
    dnf install -y \
    bsdtar-3.7.4 \
    git-2.50.1 \
    openssh-clients-9.9p1 \
    pip \
    tar-1.34 \
    unzip-6.0 \
    wget && \
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
