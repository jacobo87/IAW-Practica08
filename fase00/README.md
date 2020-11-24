# Fase 00
### Herramientas para instalar un servidor Wordpress 
Contenido de la **fase00**:

- ```000-default.conf```:
	- Archivo de configuración con acceso restringido a la carpeta ```stats```. 
    > Este archivo lo usaremos si más a delante queremos instalar herramientas adicionales para nuestro sitio. 

- ```config.inc.php```:
	- Archivo de configuración php para que los módulos de la base de datos puedan acceder a ella.

- ```database.sql```:
	- Script para Wordpress.

- ```lamp_wordpress.sh```:
	- Script de la pila lamp con:
		- Instalación de Apache.
		- Instalación de Wordpress.
		- Instalación de herramienta para descomprimir **Zip**.
		- Instalación de phpMyAdmin.
		- Instalación de MySQL Server.

- ```wp-config.php```:
	- Archivo de configuración para la base de datos php de Wordpress.

- ```info.php```:
	- Archivo de información php.