#!/bin/bash

# ####################################
# ## CONFIGURACIÓN DE LAS VARIABLES ##
# ####################################

# Directorio de usuario #
HTTPASSWD_DIR=/home/ubuntu

# MySQL #
DB_ROOT_PASSWD=root
DB_NAME=wordpress_db
DB_USER=wordpress_user
DB_PASSWORD=wordpress_password
IP_BALANCEADOR=
#IP_MYSQL_SERVER=

# PhPMyAdmin #
PHPMYADMIN_PASSWD=`tr -dc A-Za-z0-9 < /dev/urandom | head -c 64`


# #################################
# ## Instalación de la pila LAMP ##
# #################################

set -x
# Actualizamos los repositorios
apt update
# Instalamos Apache 
apt install apache2 -y
# Instalamos MySQL Server 
apt install mysql-server -y
# Instalamos módulos PHP 
apt install php libapache2-mod-php php-mysql -y
# Reiniciamos el servicio Apache 
systemctl restart apache2
# Copiamos el archivo info.php al directorio html 
cp $HTTPASSWD_DIR/info.php /var/www/html

# Configuramos las opciones de instalación de phpMyAdmin
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_PASSWD" |debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_PASSWD" | debconf-set-selections

# Instalamos phpMyAdmin 
apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y

# ##############################
# ## Instalación de Wordpress ##
# ##############################

# Nos movemos al raíz de Apache 
cd /var/www/html

# Descargamos la última versión de Wordpress 
wget http://wordpress.org/latest.tar.gz
# Eliminamos instalaciones anteriores 
rm -rf /var/www/html/wordpress
# Descomprimimos el archivo que acabamos de descargar 
tar -xzvf latest.tar.gz
# Eliminamos lo que ya no necesitamos 
rm latest.tar.gz


# Creamos la base de datos que vamos a usar con Wordpress #

# Nos aseguramos que no existe ya, y si existe la borramos
mysql -u root <<< "DROP DATABASE IF EXISTS $DB_NAME;"
# Creamos la base de datos
mysql -u root <<< "CREATE DATABASE $DB_NAME;"
# Nos aseguramos que no existe el usuario
mysql -u root <<< "DROP USER IF EXISTS $DB_USER@localhost;"
# Creamos el usuario para Wordpress
mysql -u root <<< "CREATE USER $DB_USER@localhost IDENTIFIED BY '$DB_PASSWORD';"
# Concedemos privilegios al usuario que acabamos de crear
mysql -u root <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@localhost;"
# Aplicamos cambios
mysql -u root <<< "FLUSH PRIVILEGES;"


# Borramos el index.html de Apache
rm /var/www/html/index.html


# Configuramos el archivo wp-config.php #

# Renombramos el archivo config
mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

# Definimos variables dentro del archivo config
sed -i "s/database_name_here/$DB_NAME/" /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/$DB_USER/" /var/www/html/wordpress/wp-config.php
sed -i "s/password_here/$DB_PASSWORD/" /var/www/html/wordpress/wp-config.php
#sed -i "s/localhost/$IP_MYSQL_SERVER/" /var/www/html/wordpress/wp-config.php


# Configuración de Wordpress en un directorio que no es el raíz #

# Cambiamos la url de WordPress con WP_SITEURL y WP_HOME 
#sed -i "#DB_COLLATE#a define( 'WP_SITEURL', 'http://$IP_BALANCEADOR/wordpress' );" /var/www/html/wordpress/wp-config.php
#sed -i "#WP_SITEURL#a define( 'WP_HOME', 'http://$IP_BALANCEADOR' );" /var/www/html/wordpress/wp-config.php
#[SEGUIMOS HACIÉNDOLO MANUALMENTE, NO SABEMOS CÓMO AUTOMATIZAR]----------------------------------------------------------

# Copiamos el archivo /var/www/html/wordpress/index.php a /var/www/html/index.php
cp /var/www/html/wordpress/index.php  /var/www/html/index.php

# Editamos el archivo /var/www/html/index.php
sed -i "s#/wp-blog-header.php#/wordpress/wp-blog-header.php#" /var/www/html/index.php

# Copiamos el archivo htaccess 
cp $HTTPASSWD_DIR/htaccess /var/www/html/.htaccess

# Configuramos las keys para el cifrado de las cookies #

# Borramos el bloque que nos viene por defecto en el archivo de configuración
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