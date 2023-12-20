FROM centos:8

ARG ANSIBLE_VERSION=2.9.10
ARG PACKER_VERSION=1.6.0

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN yum install -y epel-release \
                openssh-clients \
                git \
                wget \
                bsdtar \
                python3-pip && \
                alternatives --set python /usr/bin/python3

RUN python3 -m pip install --upgrade pip

RUN pip3 install ansible==${ANSIBLE_VERSION} \
                 boto \
                 boto3 \
                 dnspython \
                 netaddr

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
