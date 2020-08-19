#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo systemctl enable apache2
sudo mkdir -p /var/www/html
sudo touch /var/www/html/index.html
sudo bash -c 'echo "<h1>Hello, this is a terraform-ed AWS Web Server</h1>" > /var/www/html/index.html'