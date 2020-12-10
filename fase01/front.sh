#! /bin/bash

# ################
# ##### FRONT #####
# ################
IPMYSQL=172.31.20.186
# --------------------------------------------------------------------------
# #################  Configuracion del scritp  #############################
# --------------------------------------------------------------------------
# Definimos la ruta donde vamos a guardar el archivo .htpasswd
HTTPASSWD_DIR=/home/ubuntu
HTTPASSWD_USER=usuario
HTTPASSWD_PASSWD=usuario
# Definimos la contraseña de root como variable
DB_ROOT_PASSWD=root
# PhPMyAdmin #
PHPMYADMIN_PASSWD=`tr -dc A-Za-z0-9 < /dev/urandom | head -c 64`
# Mostramos comandos
set -x
# Actualizamos repositorios
apt update
# ------------------------------ Instalamos Front-end ----------------------------------------
# Eliminamos instalaciones anteriones
rm -rf /var/www/html/*
# Instalamos Servidor Web Apache
apt install apache2 -y
# Instalamos los módulos necesarios de PHP
apt install php libapache2-mod-php php-mysql -y
# Habilitamos el modulo mod_rewrite
# Copiamos info.php
cp info.php /var/www/html
# Nos movemos al directorio de Apache
cd /var/www/html
# Instalamos Wordpress
wget https://wordpress.org/latest.tar.gz
# Eliminiamos instalaciones anteriores
rm -rf /var/www/html/wordpress
# Descomprimimos .tar .gz
tar -xzvf latest.tar.gz
# Eliminamos .tar.gz
rm latest.tar.gz
# Copiamos el archivo de configuración
cp /home/ubuntu/wp-config.php /var/www/html/wordpress/
# Introducimos la IP de MySQL en el archivo de configuración php
sed -i "s/localhost/$IPMYSQL/" /var/www/html/wordpress/wp-config.php
# Modificamos Unique Keys del archivo de configuracion de WP borramos wp-config.conf
sed -i "/AUTH_KEY/d" /var/www/html/wordpress/wp-config.php       
sed -i "/SECURE_AUTH_KEY/d" /var/www/html/wordpress/wp-config.php
sed -i "/LOGGED_IN_KEY/d" /var/www/html/wordpress/wp-config.php   
sed -i "/NONCE_KEY/d" /var/www/html/wordpress/wp-config.php       
sed -i "/AUTH_SALT/d" /var/www/html/wordpress/wp-config.php       
sed -i "/SECURE_AUTH_SALT/d" /var/www/html/wordpress/wp-config.php
sed -i "/LOGGED_IN_SALT/d" /var/www/html/wordpress/wp-config.php  
sed -i "/NONCE_SALT/d" /var/www/html/wordpress/wp-config.php
# Definimos la variable SECURITY_KEYS haciendo una llamada a la API de Wordpress
SECURITY_KEYS=$(curl https://api.wordpress.org/secret-key/1.1/salt/)
# Reemplazamos "/" por "_" para que no nos falle el comando sed
SECURITY_KEYS=$(echo $SECURITY_KEYS | tr / _)
# Creamos un nuevo bloque de SECURITY KEYS
sed -i "/@-/a $SECURITY_KEYS" /var/www/html/wordpress/wp-config.php

# Habilitamos el módulo rewrite (reescritura de las url)
a2enmod rewrite

# Le damos permiso a la carpeta de wordpress
chown -R www-data:www-data /var/www/html

# Reiniciamos Apache
systemctl restart apache2
# ------------------------------------ Inslación de herramientas adicionales ------------------------------
# Instalamos unzip
apt install unzip -y
# Instalación de Phpmyadmin
cd /home/ubuntu
rm -rf phpMyAdmin-5.0.4-all-lenguages.zip
wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.zip
# Descomprimimos 
unzip phpMyAdmin-5.0.4-all-languages.zip
# Borramos el archivo .zip
rm -rf phpMyAdmin-5.0.4-all-languages.zip
rm -rf /var/www/html/phpmyadmin
# Movemos la carpeta al directorio
mv phpMyAdmin-5.0.4-all-languages /var/www/html/phpmyadmin
# Configuaramos el archivo config.sample.inc.php
sed -i "s/localhost/$IPMYSQL/" /home/ubuntu/config.inc.php 
cp config.inc.php /var/www/html/phpmyadmin/
rm /var/www/html/index.html
# Copiamos el archivo index.php
cp /var/www/html/wordpress/index.php /var/www/html/
# modificamos el directorio por defecto
sed -i "s#wp-blog-header.php#wordpress/wp-blog-header.php#" /var/www/html/index.php
# Reiniciamos Apache
systemctl restart apache2
# Borramos lo que no necesitamos
rm back.sh README.md database.sql
rm -r IAW-Practica08/ wordpress/ config.inc.php front.sh  info.php  wp-config.php