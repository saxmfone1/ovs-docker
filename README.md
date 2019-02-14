ovs-docker
==========

This will boot up container which allows you to add an ovs bridge
to docker containers without having to install ovs on your system

Because of this magic, it needs access to:
- Docker
- Host Networking namespace
- NET_ADMIN
- privileged

The docker run command should end up looking something like:

```docker run -d --name ovs-docker --cap-add NET_ADMIN --privileged --pid host -v /var/run/docker.sock:/var/run/docker.sock ovs-docker:develop```

Almost all of this has been cobbled together from various open source providing different aspects, but never an all in one package. Probably for good reason.

https://github.com/openvswitch/ovs/blob/master/utilities/ovs-docker

https://github.com/socketplane/docker-ovs

https://github.com/joatmon08/vagrantfiles/blob/master/ovs-vagrant/bootstrap.sh
