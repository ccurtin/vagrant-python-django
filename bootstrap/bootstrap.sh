#!/bin/bash

# $1 = synced_folder['host']
# $2 = guest_port
# $3 = git global user.name
# $4 = git global user.email



# TO DO: ADD SUPPORT FOR DB INTERACTION:
#   POSTGRESQ python2.7:
#     sudo apt-get install libpq-dev python-dev postgresql postgresql-contrib postgresql-client postgresql-client-common

# Make default Projects Directory. /vagrat/www/
if [ ! -d "/vagrant/${1%/}/" ]; then
  sudo mkdir "/vagrant/${1%/}/"
  # echo 'deactivate' >> "/vagrant/$1/.env"
  # echo 'alias python=/usr/bin/python' >> "/vagrant/$1/.env"
fi

# Update available python packages.
sudo add-apt-repository ppa:fkrull/deadsnakes
# Install latest version of git.
sudo add-apt-repository ppa:git-core/ppa -y

# Update apt-get before installing.
sudo apt-get update

# Install Git.
sudo apt-get install -y git
# Create global config file and write user.name and user.email if configured.
if [ -f /root/.gitconfig ]; then
  touch /root/.gitconfig
fi
  chmod +x /root/.gitconfig
if [[ ! -z ${3} ]]; then
  git config --global user.name "${3}"
fi
if [[ ! -z ${4} ]]; then
  git config --global user.email "${4}"
fi

# Allow virtualenvs for self-contained Python environments.
sudo apt-get install -y python-virtualenv
sudo pip install virtualenv
sudo pip install virtualenvwrapper
sudo pip install autoenv


# Let's configure PS1 so there is less confusion.
# Show the user and folder \n virtualenv and branch name

curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o /bin/.git-prompt.sh

# Must write below to /etc/bash.bashrc and NOT ~/.bashrc or ~/.bash_profile 
# so that environments work for sudo AND unprivileged users.
# 
# Load in the git branch prompt script.
echo "source /bin/.git-prompt.sh" >> /etc/bash.bashrc

# add to new PS1 prompt to bashrc
echo "source /bin/better_ps1" >> /etc/bash.bashrc
# `WORKON_HOME` tells virtualenvwrapper where to place your virtual environments
echo "WORKON_HOME=/vagrant/${1%/}/" >> /etc/bash.bashrc
echo 'source /usr/local/bin/virtualenvwrapper.sh' >> /etc/bash.bashrc
echo 'source /usr/local/bin/activate.sh' >> /etc/bash.bashrc

# make sure virtualenv wrapper is properly setup for python switching.
echo 'VIRTUALENVWRAPPER_PYTHON=/usr/bin/python' >> /etc/bash.bashrc
echo 'VIRTUALENVWRAPPER_VIRTUALENV=/usr/bin/virtualenv' >> /etc/bash.bashrc

# Make sync_folder accessible to new script.
echo "SYNC_FOLDER=${1%/}" >> /etc/bash.bashrc
echo "export SYNC_FOLDER=${1%/}" >> /etc/bash.bashrc

# Reload system environment variables so they are immediately available.
source /etc/bash.bashrc