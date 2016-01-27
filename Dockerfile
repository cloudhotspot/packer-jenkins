FROM jenkins
MAINTAINER Justin Menga <justin.menga@cloudhotspot.co>

ENV TERM=xterm-256color

# Change to root user
USER root

# Set mirrors to NZ
# RUN sed -i "s/http:\/\/archive./http:\/\/nz.archive./g" /etc/apt/sources.list 

# Install base packages
RUN apt-get update -y && \
    apt-get install apt-transport-https curl make -y 

# Install Docker Engine
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | tee /etc/apt/sources.list.d/docker.list && \
    apt-get update -y && \
    apt-get purge lxc-docker* -y && \
    apt-get install docker-engine -y && \
    usermod -aG users jenkins && \
    usermod -aG docker jenkins

# Install Docker Compose
RUN curl -L https://github.com/docker/compose/releases/download/1.5.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Install Ansible
RUN apt-get install python-setuptools ansible -y && \
   easy_install pip && \
   pip install ansible --upgrade

# Change to jenkins user
# USER jenkins

# Add Jenkins plugins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt