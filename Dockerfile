FROM ubuntu:18.04
ENV OVS_VERSION 2.4.0
ENV SUPERVISOR_STDOUT_VERSION 0.1.1

#INSTALL PREREQUISITES
RUN apt-get update && apt-get install -y \ 
    iproute2 \
    uuid-runtime \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    supervisor \
    wget \
    python-setuptools

#INSTALL SUPERVISOR
ADD supervisord.conf /etc/
WORKDIR /opt
RUN mkdir -p /var/log/supervisor/
RUN mkdir -p /etc/openvswitch
RUN wget https://pypi.python.org/packages/source/s/supervisor-stdout/supervisor-stdout-$SUPERVISOR_STDOUT_VERSION.tar.gz --no-check-certificate && \
	tar -xzvf supervisor-stdout-0.1.1.tar.gz && \
	mv supervisor-stdout-$SUPERVISOR_STDOUT_VERSION supervisor-stdout && \
	rm supervisor-stdout-0.1.1.tar.gz && \
	cd supervisor-stdout && \
	python setup.py install -q

#INSTALL DOCKER
WORKDIR /
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

#INSTALL OPENVSWITCH
RUN mkdir -p /etc/openvswitch
RUN wget https://s3-us-west-2.amazonaws.com/docker-ovs/openvswitch-$OVS_VERSION.tar.gz --no-check-certificate && \
	tar -xzvf openvswitch-$OVS_VERSION.tar.gz &&\
	mv openvswitch-$OVS_VERSION openvswitch &&\
	cp -r openvswitch/* / &&\
	rm -r openvswitch &&\
	rm openvswitch-$OVS_VERSION.tar.gz 
RUN cp -r /usr/local/share/openvswitch/python/ovs /usr/local/lib/python2.7/site-packages/ovs
ADD configure-ovs.sh /usr/local/share/openvswitch/ 
RUN chmod 755 /usr/local/share/openvswitch/configure-ovs.sh
RUN ovsdb-tool create /etc/openvswitch/conf.db /usr/local/share/openvswitch/vswitch.ovsschema

#INSTALL OVS-DOCKER
ADD https://raw.githubusercontent.com/openvswitch/ovs/master/utilities/ovs-docker /usr/bin/
RUN chmod 755 /usr/bin/ovs-docker

CMD ["/usr/bin/supervisord"]

