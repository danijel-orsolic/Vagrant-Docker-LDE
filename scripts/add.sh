#!/bin/bash

# This script automates deployment of new websites as docker stacks consisting of three containers: 
# examplecom (wp, php5 or lamp), examplecom-db (mysql) and examplecom-pma (phpmyadmin).
# By Danijel Orsolic

# Defining colors

red='\033[0;31m'
green='\033[0;32m'
cyan='\e[0;36m'
NC='\033[0m' # No Color

# Variables:
# $domain (ask) - VIRTUAL_HOST / LETSENCRYPT_HOST / VIRTUAL_HOST for pma = pma-$domain
# $dbrootpass (generate & show) - MYSQL_ROOT_PASSWORD - $dbrootpass
# $name (generate & show) - MYSQL_DATABASE / WORDPRESS_DB_NAME / container_name / $name = $domain without dots
# $user (ask) - MYSQL_USER / PMA_USER / WORDPRESS_DB_USER / container username for SSH
# $pass (generate & show) - MYSQL_PASSWORD / PMA_PASSWORD / WORDPRESS_DB_PASSWORD
# $email (ask) - LETSENCRYPT_EMAIL
# $sshport (generate & show) - host port for SSH to container

echo -e "${cyan}Choose the type of stack to deploy: ${NC}"
options=("WordPress" "Clean LEMP Stack" "Clean LAMP PHP7" "Clean LAMP PHP5" "Redirect")
select opt in "${options[@]}"
do
    case $opt in
        "WordPress")
            stack=wp_base
            break
            ;;
        "Clean LEMP Stack")
            stack=lemp_base
            break
            ;;
        "Clean LAMP PHP7")
            stack=lamp_php7_base
            break
            ;;
        "Clean LAMP PHP5")
            stack=lamp_php5_base
            break
            ;;
        "Redirect")
            echo -e "${cyan}Enter domain or subdomain: ${NC}"
            read subdomain
            echo -e "${cyan}Enter address to redirect to: ${NC}"
            read redirect
            echo "server { listen 80; server_name $subdomain; return 301 $redirect; }" > /home/vagrant/projects/nginx-custom-conf/$subdomain.conf
            docker exec -ti nginx-proxy bash -c "service nginx reload"
            exit
            ;;
        *) echo invalid option;;
    esac
done

echo -e "${cyan}Domain name: ${NC}"
read domain

#echo -e "${cyan}Desired username: ${NC}"
#read user
user="vagrant"

echo -e "${cyan}E-mail address: ${NC}"
read email

read -r -p "Confirm and continue? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then

# Generate $dbrootpass, $pass, $name and $sshport, append chosen port to the used_ports file

dbrootpass=$(date +%s|sha256sum|base64|head -c 32);
pass=$(pwgen -s 16 1);
name=${domain//[-._]/};
sshport=$(bash findport.sh 2200 1);
echo $sshport >> used_ports
pmaport=$(bash findport.sh 10000 1);
echo $pmaport >> used_ports

# Make the app directory and copy the base docker-compose.yml and Dockerfile there

mkdir -p /home/vagrant/projects/$domain/app
cp $stack/docker-compose.yml /home/vagrant/projects/$domain/

if [[ "$stack" == lemp_base ]]; then
cp $stack/Dockerfile /home/vagrant/projects/$domain/
mkdir /home/vagrant/projects/$domain/nginx/
mkdir /home/vagrant/projects/$domain/db/
cp $stack/default.conf /home/vagrant/projects/$domain/nginx/
cp $stack/index.php /home/vagrant/projects/$domain/app/
sed -i "s/namegoeshere/$name/g" /home/vagrant/projects/$domain/nginx/default.conf
sed -i "s/domaingoeshere/$domain/g" /home/vagrant/projects/$domain/nginx/default.conf
fi

if [[ "$stack" == lamp_php7_base ]]; then
cp $stack/Dockerfile /home/vagrant/projects/$domain/
fi

#cp $stack/Dockerfile /vagrant/projects/$domain/

# Modify the new docker-compose.yml and Dockerfiles to reflect chosen information

sed -i "s/dbrootpass/$dbrootpass/g" /home/vagrant/projects/$domain/docker-compose.yml
sed -i "s/namegoeshere/$name/g" /home/vagrant/projects/$domain/docker-compose.yml
sed -i "s/domaingoeshere/$domain/g" /home/vagrant/projects/$domain/docker-compose.yml
sed -i "s/usergoeshere/$user/g" /home/vagrant/projects/$domain/docker-compose.yml
sed -i "s/emailgoeshere/$email/g" /home/vagrant/projects/$domain/docker-compose.yml
sed -i "s/passgoeshere/$pass/g" /home/vagrant/projects/$domain/docker-compose.yml
sed -i "s/2222/$sshport/g" /home/vagrant/projects/$domain/docker-compose.yml
sed -i "s/8181/$pmaport/g" /home/vagrant/projects/$domain/docker-compose.yml

chown -R vagrant:vagrant /home/vagrant/projects/$domain

# Build the docker image
echo -e "${green}=> Building and deploying containers.. ${NC}"

#cd /vagrant/projects/$domain && docker build -t libervis/$name .
cd /home/vagrant/projects/$domain && docker-compose up -d
cd /vagrant/scripts/

#chown -R vagrant:www-data /vagrant/projects/$domain/app

# echo -e "${green}=> Setting up user access.. ${NC}"
# Install WP and base theme
#sleep 20

# docker exec -ti $name apt-get update -y
# docker exec -ti $name apt-get install openssh-server htop nano -y
# docker exec -ti $name bash -c "sed -i -e 's/#Port 22/Port $sshport/g' /etc/ssh/sshd_config"
# docker exec -ti $name useradd $user
# docker exec -ti $name usermod -aG www-data $user
# docker exec -ti $name bash -c "echo \"$user:$pass\" | chpasswd"
# docker exec -ti $name service ssh start

if [[ "$stack" == wp_base ]]; then

echo -e "${green}=> Installing WordPress and plugins.. ${NC}"
sleep 10

docker exec -ti $name bash -c "echo \"define( 'FTP_HOST', 'localhost:$sshport' );\" >> /var/www/html/wp-config.php"
docker exec -ti $name bash -c "echo \"define( 'FTP_USER', '$user' );\" >> /var/www/html/wp-config.php"
docker exec -ti $name bash -c "echo \"define( 'FTP_PASS', '$pass' );\" >> /var/www/html/wp-config.php"
docker exec -ti $name bash -c "echo \"define( 'FS_METHOD', 'direct' );\" >> /var/www/html/wp-config.php"
docker exec -ti $name bash -c "echo \"define( 'FTP_BASE', '/var/www/html/' );\" >> /var/www/html/wp-config.php"
docker exec -ti $name bash -c "chown -R $user:www-data /var/www/html/*"
docker exec -ti $name bash -c "chmod g+wx -R /var/www/html/*"
docker exec -ti $name bash -c "chown -R $user:www-data /var/www/html"
docker exec -ti $name bash -c "chmod g+wx -R /var/www/html"
fi

fi # Ends the confirmation loop for domain, user, and email

# Dispay the information:

echo -e "${cyan}Domain: $domain ${NC}"
echo -e "${cyan}Username: $user ${NC}"
echo -e "${cyan}Password: $pass ${NC}"
echo -e "${cyan}MySQL root password: $dbrootpass ${NC}"