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

# Mostramos comandos
set -x
# Actualizamos repositorios
apt update
# ------------------------------ Instalamos Front-end ----------------------------------------
# Instalamos Servidor Web Apache
apt install apache2 -y
# Instalamos los módulos necesarios de PHP
apt install php libapache2-mod-php php-mysql -y
# Habilitamos el modulo mod_rewrite
# Copiamos info.php
cp info.php /var/www/html
# Instalamos Wordpress
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
# Eliminamos .tar.gz
rm latest.tar.gz
# Copiamos el archivo de configuración php
sed -i "s/localhost/$IPMYSQL/" /home/ubuntu/wp-config.php
# Modificamos Unique Keys del archivo de configuracion de WP
# Borramos 
sed -i "/AUTH_KEY/d" /var/www/html/wordpress/wp-config.php       
sed -i "SECURE_AUTH_KEY/d"  /var/www/html/wordpress/wp-config.php
sed -i "LOGGED_IN_KEY/d" /var/www/html/wordpress/wp-config.php   
sed -i "NONCE_KEY/d" /var/www/html/wordpress/wp-config.php       
sed -i "AUTH_SALT/d" /var/www/html/wordpress/wp-config.php       
sed -i "SECURE_AUTH_SALT/d" /var/www/html/wordpress/wp-config.php
sed -i "LOGGED_IN_SALT/d" /var/www/html/wordpress/wp-config.php  
sed -i "NONCE_SALT/d" /var/www/html/wordpress/wp-config.php

SECURITY_KEYS=$(https://api.wordpress.org/secret-key/1.1/salt/)
# Reemplaza el caracter / por el _
SECURITY_KEYS=$(echo $SECURITY_KEYS | tr / _)
# Busca el contenido y lo añade después
sed -i "/@-/a $SECURITY_KEYS/" /var/www/html/wordpress/wp-config.php

cp wp-config.php /var/www/html/wordpress
rm /var/www/html/index.html
# Cambiamos permisos 
chown www-data:www-data * -R
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
sed -i "s#wp-blog-header.php#/wordpress/wp-blog-header.php#" /var/www/html/index.php
# Reiniciamos Apache
systemctl restart apache2
# Borramos lo que no necesitamos
rm back.sh README.md database.sql