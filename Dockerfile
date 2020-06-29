FROM centos:7.6.1810

# Install essentials
RUN yum install -y epel-release
RUN yum install -y openssh-clients-7.4p1-16.el7
RUN yum install -y git-1.8.3.1-20.el7

# Install bsdtar and wget
# TODO: Offload this to a builder when we refine these images. For now we'll just install it
RUN yum install -y bsdtar-3.1.2-10.el7_2
RUN yum install -y wget-1.14-18.el7_6.1

# Clean up after ourselves
RUN yum clean all

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
