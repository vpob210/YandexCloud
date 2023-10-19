#!/bin/bash -eux

# Install docker-ce dependencies.
apt -y update && apt-get -y upgrade
apt -y install python-pip python-dev apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common

# Add Docker’s official GPG key.
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

# Add apt repo with docker ce.
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

# Install docker
apt -y update 
apt -y install docker-ce docker-ce-cli containerd.io

# Also install nginx
apt -y install nginx
