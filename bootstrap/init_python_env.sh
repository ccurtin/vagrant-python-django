#!/bin/bash
# $1 = ENV_NAME
# $2 = PYTHON_VERSION
# $3 = DJANGO_VERSION
#
# need access to `$SYNC_FOLDER`
source /etc/bash.bashrc

read -p "Enter a folder/name for the new environment: " ENV_NAME
read -p "Enter Python version you'd like to install: " PYTHON_VERSION
read -p "Enter Django version you'd like to install(hit return to skip): " DJANGO_VERSION

# Navigate to root web dir.
cd /vagrant/$SYNC_FOLDER/
# Check if the Python Version is already installed.
if [[ ! $(which python$PYTHON_VERSION) ]]; then
    sudo apt-get install -y python$PYTHON_VERSION
fi
source /usr/local/bin/virtualenvwrapper.sh
mkvirtualenv $ENV_NAME -p /usr/bin/python$PYTHON_VERSION --always-copy
echo "if [ -f \"/vagrant/$SYNC_FOLDER/$ENV_NAME/.env\" ]
then
  workon $ENV_NAME
fi" >> /vagrant/$SYNC_FOLDER/$ENV_NAME/.env
# activate project to update `$VIRTUAL_ENV`
workon $ENV_NAME
# be SURE the env is active before installing Django or other packages.
cd /vagrant/$SYNC_FOLDER/$ENV_NAME
if [[ ! -z $DJANGO_VERSION ]]; then
    workon $ENV_NAME
    pip install django==$DJANGO_VERSION
    read -p 'Create a New Django Project: ' DJANGO_PROJECT_NAME
    django-admin startproject "$DJANGO_PROJECT_NAME" /vagrant/$SYNC_FOLDER/$ENV_NAME/

    read -p "Setup a New Database For Your Project? [y/n] " prompt
    if [[ ${prompt,,} =~ ^(yes|y)$ ]]; then
        . manage_django_db
    fi
fi
