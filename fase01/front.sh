#! /bin/bash

# ################
# ##### FRONT #####
# ################

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
# Copiamos info.php
cp info.php /var/www/html
# Instalamos Wordpress
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
# Eliminamos .tar.gz
rm latest.tar.gz
# Movemos el contenido de Wordpress al raiz de Apache
cp -r wordpress/ /var/www/html
# Copiamos el archivo de configuración php
cp wp-config.php /var/www/html/wordpress
rm /var/www/html/index.html
cp -r /var/www/html/wordpress/* /var/www/html
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