#!/bin/bash
# PREPHOST for docker based multiple websites setup
# Initial update, upgrade, and install of docker and docker-compose

apt update
apt upgrade
apt install docker.io -y
apt install docker-compose -y
apt install htop
apt install cockpit
apt install pwgen

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
su vagrant -c 'mkdir /vagrant/projects'

su vagrant -c 'cd /vagrant/scripts/nginx-proxy/ && docker-compose up -d'

touch used_ports

# docker-compose.yml and Dockerfile should be in /home/vagrant/scripts/wp_base (and php5_base and lamp_base)
# nginx-proxy docker-compose.yml should be in scripts/nginx-proxy

# devpass: hij1TamaephahS6a
