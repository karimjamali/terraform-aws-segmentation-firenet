#!/bin/bash

apt update && apt -y upgrade
apt-get -y purge apache2
apt-get -y install nginx
unlink /etc/nginx/sites-enabled/default
export web_server_ip=${web_ip}
cd /etc/nginx/sites-available/
echo -e "
events {}
http {
server {
listen 80;
access_log off;
error_log off;
location / {
proxy_pass http://$web_server_ip/;
}
}}" > /etc/nginx/nginx.conf
systemctl restart nginx 





