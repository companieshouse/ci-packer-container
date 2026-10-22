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

RUN yum install -y epel-release \
                   openssh-clients \
                   git \
                   bsdtar \
                   wget && \
                   yum clean all

# Install Ansible and required pip libraries
COPY resources/get-pip.py /get-pip.py
RUN python /get-pip.py
RUN pip install ansible==2.8.1
RUN pip install boto==2.49.0
RUN pip install boto3==1.9.201
RUN pip install dnspython==1.16.0
RUN pip install netaddr==0.7.19

# Remove conflicting symlink
RUN unlink /usr/sbin/packer

# Install Packer
# TODO: Retrieve this from a reliable source such as an S3 bucket
RUN wget -qO- https://releases.hashicorp.com/packer/1.4.2/packer_1.4.2_linux_amd64.zip | bsdtar -xvf- -C /usr/bin/
RUN chown root:root /usr/bin/packer
RUN chmod 755 /usr/bin/packer

# Create packer user
RUN useradd -ms /bin/bash packer
USER packer
