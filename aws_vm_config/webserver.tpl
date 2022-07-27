#!/bin/bash

sudo su 
apt update && apt upgrade
apt -y install apache2
systemctl enable apache2
apt -y install php ghostscript libapache2-mod-php mysql-server php php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip
sudo mkdir -p /srv/www
sudo chown www-data: /srv/www
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www
sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php
echo -e "<VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>" > /etc/apache2/sites-available/wordpress.conf 
sudo a2ensite wordpress
sudo a2enmod rewrite
sudo a2dissite 000-default
sudo sed -i 's/database_name_here/wordpress/g' /srv/www/wordpress/wp-config.php
sudo sed -i 's/password_here/Aviatrix/g' /srv/www/wordpress/wp-config.php
export database_ip=${db_ip}
sudo sed -i "s/localhost/$database_ip/g" /srv/www/wordpress/wp-config.php
sudo sed -i 's/username_here/wordpress/g' /srv/www/wordpress/wp-config.php

systemctl restart apache2

