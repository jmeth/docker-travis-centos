# docker :: CentOS Container for Travis CI
---

## Description
Travis CI uses Ubuntu hosts for running automated tests.  In order to test ansible roles against other systems it is necessary to use Docker Containers.  This container builds CentOS (currently only 7) with ansible pre-installed for use in testing the ansible roles.

## Limitations
Docker containers are not full VMs and are lacking in certain components that may cause Ansible Roles to fail:
* systemd - This container attempts to configure a basic version of systemd
* firewalld - Not installed by default
* selinux - Not usable inside a container
And many more that I'm not smart enough to be aware of.

## Running
Use the following template `.travis.yml` file to leverage this container:
```
sudo: required

services:
  - docker

before_install:
  # Fetch base image
  - sudo docker pull jmeth/travis-centos

script:
  # Run container in detached state
  - sudo docker run --detach --privileged --volume="${PWD}":/etc/ansible/roles/role_under_test:ro --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro travispoc /usr/lib/systemd/systemd > /tmp/container_id
  # Check syntax of ansible playbook
  - sudo docker exec "$(cat /tmp/container_id)" ansible-playbook /etc/ansible/roles/role_under_test/test.yml --syntax-check
  # Run ansible playbook
  - sudo docker exec "$(cat /tmp/container_id)" ansible-playbook /etc/ansible/roles/role_under_test/test.yml
  # Clean up
  - sudo docker stop "$(cat /tmp/container_id)"

notifications:
  email: false
```

## Source
This container was built following this blog [post](http://bertvv.github.io/notes-to-self/2015/12/11/testing-ansible-roles-with-travis-ci-part-1-centos/)