#! /bin/bash
# ################
# ##### FRONT #####
# ################
# --------------------------------------------------------------------------
# #################  Configuracion del scritp  #############################
# --------------------------------------------------------------------------
# Definimos la contraseña de root como variable
DB_ROOT_PASSWD=root
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
# sed -i "s/localhost/$IPMYSQL/" /var/www/html/wordpress/wp-config.php
# Modificamos Unique Keys del archivo de configuracion de WP borramos wp-config.conf
sed -i "/AUTH_KEY/d" /var/www/html/wordpress/wp-config.php       
sed -i "/SECURE_AUTH_KEY/d" /var/www/html/wordpress/wp-config.php
sed -i "/LOGGED_IN_KEY/d" /var/www/html/wordpress/wp-config.php   
sed -i "/NONCE_KEY/d" /var/www/html/wordpress/wp-config.php       
sed -i "/AUTH_SALT/d" /var/www/html/wordpress/wp-config.php       
sed -i "/SECURE_AUTH_SALT/d" /var/www/html/wordpress/wp-config.php
sed -i "/LOGGED_IN_SALT/d" /var/www/html/wordpress/wp-config.php  
sed -i "/NONCE_SALT/d" /var/www/html/wordpress/wp-config.php
# Creamos la variable con la salida de la api
SECURITY_KEYS=`curl https://api.wordpress.org/secret-key/1.1/salt/`
# Reemplaza el caracter / por el _
SECURITY_KEYS=$(echo $SECURITY_KEYS | tr / _)
# Busca el contenido y lo añade después
sed -i "/@-/a $SECURITY_KEYS/" /var/www/html/wordpress/wp-config.php
# cp wp-config.php /var/www/html/wordpress
rm /var/www/html/index.html
# Cambiamos permisos 
chown www-data:www-data * -R
rm /var/www/html/index.html
# Copiamos el archivo index.php
cp /var/www/html/wordpress/index.php /var/www/html/
# modificamos el directorio por defecto
# sed -i "s#wp-blog-header.php#wordpress/wp-blog-header.php#" /var/www/html/index.php
# Reiniciamos Apache
systemctl restart apache2
# ################
# ##### BACK #####
# ################
# --------------------------------------------------------------------------
# #################  Configuracion del scritp  #############################
# --------------------------------------------------------------------------
# Definimos la contraseña de root como variable
DB_ROOT_PASSWD=root
# Variable de la DB
WPDB=wp_db
WPUSER=wp_user
WPPASS=wp_pass
# ----------------------------- Back-end -----------------------------------------------------
# Instalamos el sistema gestor de base de datos
apt install mysql-server -y
# Instalamos los módulos necesarios de PHP
apt install php libapache2-mod-php php-mysql -y
# Editamos el archivo de configuración de MySQL, modificando la línea 
# sed -i "s/127.0.0.1/$IPWEB/" /etc/mysql/mysql.conf.d/mysqld.cnf 
# Reiniciamos el servicio
sudo /etc/init.d/mysql restart
# Actualizamos la contraseña de root de MySQL
mysql -u root <<< "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$DB_ROOT_PASSWD';" 
# mysql -u root <<< "FLUSH PRIVILEGES;"
# Creamos la base de datos para wordpress
mysql -u root <<< "DROP DATABASE IF EXISTS $WPDB;"
mysql -u root <<< "CREATE DATABASE $WPDB CHARSET utf8mb4;"
mysql -u root <<< "USE $WPDB;"
mysql -u root <<< "CREATE USER IF NOT EXISTS '$WPUSER'@'localhost';"
mysql -u root <<< "SET PASSWORD FOR '$WPUSER'@'localhost' = '$WPPASS';"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WPDB.* TO 'WPUSER'@'%';"
mysql -u root <<< "FLUSH PRIVILEGES;"
# Introducimos la base de tados de Wordpress
# mysql -u root -p$DB_ROOT_PASSWD < /home/ubuntu/database.sql
# Borramos lo que no necesitamos
rm front.sh README.md info.php wp-config.php 
rm -r IAW-Practica08/ back.sh config.inc.php database.sql