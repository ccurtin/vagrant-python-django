#!/bin/bash
source /bin/colors
# INSTALL PHPPGADMIN
sudo apt-get install phppgadmin
# configure Apache server to tell it where to find phppgadmin.
sudo echo 'Include /etc/apache2/conf.d/phppgadmin' >>  /etc/apache2/apache2.conf
# allow permission to access phppgadmin.
sed -i 's/^allow from 127.0.0.0\/255.0.0.0 ::1\/128/# allow from 127.0.0.0\/255.0.0.0 ::1\/128/' /etc/apache2/conf.d/phppgadmin
sed -i 's/^#allow from all/allow from all/' /etc/apache2/conf.d/phppgadmin
sed -i 's/^# allow from all/allow from all/' /etc/apache2/conf.d/phppgadmin
sudo service apache2 reload
echo -e ${BYELLOW}Update password for user "postgres"${NIL}
# Create a new password for user "postgres"
sudo -u postgres psql -tAc "\password postgres"
# enable user "postgres" to login
sudo sed -i "s/\s*\$conf\['extra_login_security'\] = true;/        \$conf\['extra_login_security'\] = false;/" /etc/phppgadmin/config.inc.php
sudo sed -i "s/\s*local\s*all\s*all\s*peer/local                  all               all                   md5/" /etc/postgresql/9.3/main/pg_hba.conf
sudo service postgresql restart
# Update port 80 to port 8080
sudo sed -i "s/Listen 80/Listen 8080/" /etc/apache2/ports.conf
sudo sed -i "s/:80>/:8080>/" /etc/apache2/sites-available/000-default.conf
sudo /etc/init.d/apache2 restart

echo -e ${BGREEN}"phpPgAdmin accessible at: http://localhost:8080/phppgadmin/"${NIL}