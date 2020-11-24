#! /bin/bash

# ################
# ##### LAMP #####
# ################

# Configuracion del scritp
# Definimos la ruta donde vamos a guardar el archivo .htpasswd
HTTPASSWD_DIR=/home/ubuntu
HTTPASSWD_USER=usuario
HTTPASSWD_PASSWD=usuario
# Definimos la contraseña de root como variable
DB_ROOT_PASSWD=root
# IP de nuestro servidor
IPPRIVADA=172.31.89.73
# Mostramos comandos
set -x
# Actualizamos repositorios
apt update
# ------------------------------ Instalamos Front-end ----------------------------------------
# Instalamos Servidor Web Apache
apt install apache2 -y
# Instalamos Wordpress
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
# Movemos el contenido de Wordpress al raiz de Apache
cp -r wordpress/ /var/www/html
# Copiamos el archivo de configuración php
cp config.php /var/www/html/wordpress
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
cp config.inc.php /var/www/html/phpmyadmin/
systemctl restart apache2
# ----------------------------- Back-end -----------------------------------------------------
# Instalamos el sistema gestor de base de datos
apt install mysql-server -y
# Editamos el archivo de configuración de MySQL, modificando la línea 
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf 
# Reiniciamos el servicio
sudo /etc/init.d/mysql restart
# Actualizamos la contraseña de root de MySQL
mysql -u root <<< "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$DB_ROOT_PASSWD';" 
mysql -u root <<< "FLUSH PRIVILEGES;"
# Instalamos los módulos necesarios de PHP
apt install php libapache2-mod-php php-mysql -y
# Introducimos la base de tados de Wordpress
mysql -u root -p$DB_ROOT_PASSWD < /home/ubuntu/database.sql
