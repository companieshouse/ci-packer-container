# ci-packer-container
Provides a Docker image that contains packer and ansible and will be used to provision AMI builds

## Prerequisites

The scripts have been developed and tested using:

- [Docker](https://www.docker.com/) (2.3.0.3)

## Software

The container has been built with the following versions installed on it:

Name                    | Description                                                          | Example
----------------------- | -------------------------------------------------------------------- | ------------
packer_version          | Packer version installed on the container                            | 1.8.7
ansible_version         | Ansible version installed on the container                           | 2.10.17

## Versioning

The images are built and tagged with Concourse and have the following prefix:

```
packer-1.8.7-ansible-2.10.17-container-<CONTAINER_VERSION>
```
The `CONTAINER_VERSION` follows the semantic versioning approach.
