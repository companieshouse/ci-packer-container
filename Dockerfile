FROM centos:7.6.1810

# Deny use of the compromised eMudhra intermediate CA certificates.
# The AL2023 distro is already distrusting the intermediate CA, but
# still trusts the root cert.  This blacklists the required roots.
# Taken from https://emudhra.we-have-a-problem.com/
RUN d=/etc/pki/ca-trust/source/blocklist; [ -d "$d" ] || d=/etc/pki/ca-trust/source/blacklist; \
    trust extract --overwrite --format=pem-bundle \
    --filter='pkcs11:object=Comodo%20AAA%20Services%20root;type=cert' \
    "$d"/Comodo_AAA_Services_root.pem && \
    trust extract --overwrite --format=pem-bundle \
    --filter='pkcs11:object=emSign%20ECC%20Root%20CA%20-%20G3;type=cert' \
    "$d"/emSign_ECC_Root_CA_-_G3.pem && \
    update-ca-trust

# Install essentials
# adding sed command to look up in vault
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN yum install -y epel-release-7-11 \
                   openssh-clients-7.4p1-23.el7_9 \
                   git-1.8.3.1-25.el7_9 \
                   bsdtar-3.1.2-14.el7_7 \
                   wget-1.14-18.el7_6.1 && \
                   yum clean all

# Install Ansible and required pip libraries
COPY resources/get-pip.py /get-pip.py
# hadolint ignore=DL3059
RUN python /get-pip.py
# hadolint ignore=DL3059
RUN pip install --no-cache-dir ansible==2.8.1 \
    boto==2.49.0 \
    boto3==1.9.201 \
    dnspython==1.16.0 \
    netaddr==0.7.19

# Remove conflicting symlink
# hadolint ignore=DL3059
RUN unlink /usr/sbin/packer

# Install Packer
# TODO: Retrieve this from a reliable source such as an S3 bucket
# hadolint ignore=DL4006
RUN wget -qO- https://releases.hashicorp.com/packer/1.4.2/packer_1.4.2_linux_amd64.zip | bsdtar -xvf- -C /usr/bin/
# hadolint ignore=DL3059
RUN chown root:root /usr/bin/packer
# hadolint ignore=DL3059
RUN chmod 755 /usr/bin/packer

# Create packer user
# hadolint ignore=DL3059
RUN useradd -ms /bin/bash packer
USER packer
