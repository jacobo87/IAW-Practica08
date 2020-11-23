#! /bin/bash

# ################
# ##### LAMP #####
# ################
set -x
# Actualizamos repositorios
apt update
# Instalamos Servidor Web Apache
apt install apache2 -y
# Instalamos Wordpress
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
# Movemos el contenido de Wordpress al raiz de Apache
cp -r wordpress/ /var/www/html

