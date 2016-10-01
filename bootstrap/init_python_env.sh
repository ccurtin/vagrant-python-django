#!/bin/bash
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
echo "if [ -f \"/vagrant/$SYNC_FOLDER/${1}/.env\" ]
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

read -p 'Create a New Django Project: ' DJANGO_PROJECT_NAME
django-admin startproject "$DJANGO_PROJECT_NAME" /vagrant/$SYNC_FOLDER/${1}/

read -p "Setup a New Database For Your Project? [y/n] " prompt
if [[ ${prompt,,} =~ ^(yes|y)$ ]]; then
    . manage_djagno_db
fi