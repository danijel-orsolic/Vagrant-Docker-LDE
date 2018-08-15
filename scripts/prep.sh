#!/bin/bash
# PREPHOST for docker based multiple websites setup
# Initial update, upgrade, and install of docker and docker-compose

apt update
apt upgrade
apt install docker.io -y
apt install docker-compose -y
apt install htop -y
apt install pwgen -y
apt install npm -y

# Create swap space for database

fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Create specialized vagrant (for security)

#useradd vagrant
usermod -aG docker vagrant
usermod -aG sudo vagrant
# login vagrant

# Create a dockerweb network for linking web container sets

su vagrant -c 'docker network create nginx-proxy'
su vagrant -c 'mkdir /home/vagrant/projects'

su vagrant -c 'cd /vagrant/scripts/nginx-proxy/ && docker-compose up -d'

docker volume create portainer_data
docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

touch used_ports

# docker-compose.yml and Dockerfile should be in /vagrant/scripts/wp_base (and php5_base and lamp_base)
# nginx-proxy docker-compose.yml should be in scripts/nginx-proxy

# devpass: hij1TamaephahS6a
