#!/bin/bash
source /bin/colors
# INSTALL PHPPGADMIN
sudo apt-get install phppgadmin -y
# configure Apache server to tell it where to find phppgadmin.
echo 'Include /etc/apache2/conf.d/phppgadmin'| sudo tee --append /etc/apache2/apache2.conf
# allow permission to access phppgadmin.
sudo sed -i 's/^allow from 127.0.0.0\/255.0.0.0 ::1\/128/# allow from 127.0.0.0\/255.0.0.0 ::1\/128/' /etc/apache2/conf.d/phppgadmin
sudo sed -i 's/^#allow from all/allow from all/' /etc/apache2/conf.d/phppgadmin
sudo sed -i 's/^# allow from all/allow from all/' /etc/apache2/conf.d/phppgadmin
sudo service apache2 reload
# enable user "postgres" to login
sudo sed -i "s/\s*\$conf\['extra_login_security'\] = true;/        \$conf\['extra_login_security'\] = false;/" /etc/phppgadmin/config.inc.php
# Update port 80 to port 8080
sudo sed -i "s/\<Listen 80\>\s*/Listen 8080/" /etc/apache2/ports.conf
sudo sed -i "s/:80>/:8080>/" /etc/apache2/sites-available/000-default.conf
sudo /etc/init.d/apache2 restart

echo -e ${BGREEN}"phpPgAdmin accessible at: http://localhost:8080/phppgadmin/"${NIL}