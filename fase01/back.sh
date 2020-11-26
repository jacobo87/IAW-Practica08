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

# Mostramos comandos
set -x
# Actualizamos repositorios
apt update
# ----------------------------- Back-end -----------------------------------------------------
# Instalamos el sistema gestor de base de datos
apt install mysql-server -y
# Editamos el archivo de configuración de MySQL, modificando la línea 
sed -i 's/127.0.0.1/$IPWEB/' /etc/mysql/mysql.conf.d/mysqld.cnf 
# Reiniciamos el servicio
sudo /etc/init.d/mysql restart
# Actualizamos la contraseña de root de MySQL
mysql -u root <<< "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$DB_ROOT_PASSWD';" 
mysql -u root <<< "FLUSH PRIVILEGES;"
# Instalamos los módulos necesarios de PHP
apt install php libapache2-mod-php php-mysql -y
# Introducimos la base de tados de Wordpress
mysql -u root -p$DB_ROOT_PASSWD < /home/ubuntu/database.sql

# Borramos lo que no necesitamos
rm front.sh README.md info.php wp-config.php 