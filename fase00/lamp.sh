#! /bin/bash

####################
###### LAMP ########
####################

set -x
apt update
apt upgrade -y

apt install apache2 -y
