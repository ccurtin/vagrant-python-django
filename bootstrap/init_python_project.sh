#!/bin/bash
# Create command to quickly initialize a new ENV with Python and Django Version.
sudo touch /bin/init_python_project
sudo chmod +x /bin/init_python_project
sudo echo '
#!bin/bash
# $1 = PROJECT_NAME
# $2 = PYTHON_VERSION
# $3 = DJANGO_VERSION
#
# need access to `$SYNC_FOLDER`
source /etc/bash.bashrc
# Navigate to root web dir.
cd /vagrant/$SYNC_FOLDER/
# Check if the Python Version is already installed.
if [[ ! $(which python${2}) ]]; then
    sudo apt-get install -y python${2}
fi
source /usr/local/bin/virtualenvwrapper.sh
mkvirtualenv ${1} -p /usr/bin/python${2} --always-copy
echo "if [ -f "/vagrant/$SYNC_FOLDER/${1}/.env" ]
then
  workon ${1}
fi" >> /vagrant/$SYNC_FOLDER/${1}/.env
# be SURE the env is active before installing Django or other packages.
cd /vagrant/$SYNC_FOLDER/${1}
if [[ ! -z ${3} ]]; then
    workon ${1}
    pip install django==${3}
fi
# activate project to update `$VIRTUAL_ENV`
workon ${1}
# cd into directory via `$VIRTUAL_ENV`
cd \$VIRTUAL_ENV
' >> /bin/init_python_project