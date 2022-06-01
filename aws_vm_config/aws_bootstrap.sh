#! /bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "The page was created by the user data" | sudo tee /var/www/html/index.html
sudo apt update -y
sudo apt upgrade -y
sudo apt-get -y install  unzip build-essential git gcc hping3 apache2 net-tools



wget https://github.com/microsoft/ethr/releases/latest/download/ethr_linux.zip
sudo apt install unzip
unzip ethr_linux.zip -d /home/ubuntu/
