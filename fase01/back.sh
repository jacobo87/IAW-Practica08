#! /bin/bash

# ################
# ##### BACK #####
# ################
IPWEB=172.31.63.190
# --------------------------------------------------------------------------
# #################  Configuracion del scritp  #############################
# --------------------------------------------------------------------------
# Definimos la contraseña de root como variable
DB_ROOT_PASSWD=root
# Variable de la DB
WPDB=wp_db
WPUSER=wp_user
WPPASS=wp_pass
# Mostramos comandos
set -x
# Actualizamos repositorios
apt update
# ----------------------------- Back-end -----------------------------------------------------
# Instalamos el sistema gestor de base de datos
apt install mysql-server -y
# Editamos el archivo de configuración de MySQL, modificando la línea 
sed -i "s/127.0.0.1/$IPWEB/" /etc/mysql/mysql.conf.d/mysqld.cnf 
# Reiniciamos el servicio
sudo /etc/init.d/mysql restart
# Actualizamos la contraseña de root de MySQL
mysql -u root <<< "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$DB_ROOT_PASSWD';" 
# Creamos la base de datos para wordpress
mysql -u root <<< "DROP DATABASE IF EXISTS $WPDB;"
mysql -u root <<< "CREATE DATABASE $WPDB CHARSET utf8mb4;"
mysql -u root <<< "USE $WPDB;"
mysql -u root <<< "CREATE USER IF NOT EXISTS '$WPUSER'@'%';"
mysql -u root <<< "SET PASSWORD FOR '$WPUSER'@'%' = '$WPPASS';"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WPDB.* TO 'WPUSER'@'%';"
mysql -u root <<< "FLUSH PRIVILEGES;"
# Introducimos la base de tados de Wordpress
# mysql -u root -p$DB_ROOT_PASSWD < /home/ubuntu/database.sql
# Borramos lo que no necesitamos
rm front.sh README.md info.php wp-config.php 
rm -r IAW-Practica08/ back.sh config.inc.php database.sql
