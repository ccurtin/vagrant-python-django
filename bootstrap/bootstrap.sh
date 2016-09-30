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

# Load in the git branch prompt script.
echo "source /bin/.git-prompt.sh" >> /etc/bash.bashrc

# add to new PS1 prompt to bashrc
echo "source /bin/better_ps1.sh" >> /etc/bash.bashrc

# Must write to /etc/bash.bashrc and NOT ~/.bashrc or ~/.bash_profile so that environments work for sudo and unprivileged users.
echo "WORKON_HOME=/vagrant/${1%/}/" >> /etc/bash.bashrc
echo 'source /usr/local/bin/virtualenvwrapper.sh' >> /etc/bash.bashrc
echo 'source /usr/local/bin/activate.sh' >> /etc/bash.bashrc

# make sure virtualenv wrapper is properly setup for python switching.
echo 'VIRTUALENVWRAPPER_PYTHON=/usr/bin/python' >> /etc/bash.bashrc
echo 'VIRTUALENVWRAPPER_VIRTUALENV=/usr/bin/virtualenv' >> /etc/bash.bashrc

# Make sync_folder accessible to new script.
echo "SYNC_FOLDER=${1%/}" >> /etc/bash.bashrc
echo "export SYNC_FOLDER=${1%/}" >> /etc/bash.bashrc


# Lazy start server
touch /bin/startserver
chmod +x /bin/startserver
echo "python manage.py runserver [::]:$2" >> /bin/startserver

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



sudo touch /bin/better_ps1
sudo chmod +x /bin/better_ps1
echo '#!/bin/bash
# Thanks to Jeff Hull for this!
# Colors 
RED="'"\[\033[31m\]"'"
GREEN="'"\[\033[32m\]"'"
YELLOW="'"\[\033[33m\]"'"
BLUE="'"\[\033[34m\]"'"
PURPLE="'"\[\033[35m\]"'"
CYAN="'"\[\033[36m\]"'"
WHITE="'"\[\033[37m\]"'"
NIL="'"\[\033[00m\]"'"

# Hostname styles
FULL="'"\H"'"
SHORT="'"\h"'"

# System => color/hostname map:
# UC: username color
# LC: location/cwd color
# HD: hostname display (\h vs \H)
# Defaults:
UC=$WHITE
LC=$WHITE
HD=$FULL

# Prompt function because PROMPT_COMMAND is awesome
function set_prompt() {
    # show the host only and be done with it.
    host="${UC}${HD}${NIL}"

    # Special vim-tab-like shortpath (~/folder/directory/foo => ~/f/d/foo)
    _pwd=`pwd | sed "s#$HOME#~#"`
    if [[ $_pwd == "~" ]]; then
       _dirname=$_pwd
    else
       _dirname=`dirname "$_pwd" `
        if [[ $_dirname == "/" ]]; then
              _dirname=""
        fi
       _dirname="$_dirname/`basename "$_pwd"`"
    fi
    path="${LC}${_dirname}${NIL}"
    myuser="${UC}\u@${NIL}"

    # Dirtiness from:
    # http://henrik.nyh.se/2008/12/git-dirty-prompt#comment-8325834
    if git update-index -q --refresh 2>/dev/null; git diff-index --quiet --cached HEAD --ignore-submodules -- 2>/dev/null && git diff-files --quiet --ignore-submodules 2>/dev/null
        then dirty=""
    else
       dirty="${RED}*${NIL}"
    fi
    _branch=$(git symbolic-ref HEAD 2>/dev/null)
    _branch=${_branch#refs/heads/} # apparently faster than sed
    branch="" # need this to clear it when we leave a repo
    if [[ -n $_branch ]]; then
       branch=" ${NIL}[${GREEN}${_branch}${dirty}${NIL}]"
    fi

    # Dollar/pound sign
    end="${LC}\$${NIL} "

    # Virtual Env
    if [[ $VIRTUAL_ENV != "" ]]
       then
           venv=" ${PURPLE}(${VIRTUAL_ENV##*/})"
    else
       venv=""
    fi

    export PS1="${myuser}${path}\n${venv}${branch} ${end}"
}

export PROMPT_COMMAND=set_prompt
' >> /bin/better_ps1.sh


touch /bin/colors
chmod +x /bin/colors
echo "
# Reset
NIL='\033[0m'       # TEXT RESET

# REGULAR COLORS
BLACK='\033[0;30m'        # BLACK
RED='\033[0;31m'          # RED
GREEN='\033[0;32m'        # GREEN
YELLOW='\033[0;33m'       # YELLOW
BLUE='\033[0;34m'         # BLUE
PURPLE='\033[0;35m'       # PURPLE
CYAN='\033[0;36m'         # CYAN
WHITE='\033[0;37m'        # WHITE

# BOLD
BBLACK='\033[1;30m'       # BLACK
BRED='\033[1;31m'         # RED
BGREEN='\033[1;32m'       # GREEN
BYELLOW='\033[1;33m'      # YELLOW
BBLUE='\033[1;34m'        # BLUE
BPURPLE='\033[1;35m'      # PURPLE
BCYAN='\033[1;36m'        # CYAN
BWHITE='\033[1;37m'       # WHITE

# UNDERLINE
UBLACK='\033[4;30m'       # BLACK
URED='\033[4;31m'         # RED
UGREEN='\033[4;32m'       # GREEN
UYELLOW='\033[4;33m'      # YELLOW
UBLUE='\033[4;34m'        # BLUE
UPURPLE='\033[4;35m'      # PURPLE
UCYAN='\033[4;36m'        # CYAN
UWHITE='\033[4;37m'       # WHITE

# BACKGROUND
ON_BLACK='\033[40m'       # BLACK
ON_RED='\033[41m'         # RED
ON_GREEN='\033[42m'       # GREEN
ON_YELLOW='\033[43m'      # YELLOW
ON_BLUE='\033[44m'        # BLUE
ON_PURPLE='\033[45m'      # PURPLE
ON_CYAN='\033[46m'        # CYAN
ON_WHITE='\033[47m'       # WHITE

# HIGH INTENSITY
IBLACK='\033[0;90m'       # BLACK
IRED='\033[0;91m'         # RED
IGREEN='\033[0;92m'       # GREEN
IYELLOW='\033[0;93m'      # YELLOW
IBLUE='\033[0;94m'        # BLUE
IPURPLE='\033[0;95m'      # PURPLE
ICYAN='\033[0;96m'        # CYAN
IWHITE='\033[0;97m'       # WHITE

# BOLD HIGH INTENSITY
BIBLACK='\033[1;90m'      # BLACK
BIRED='\033[1;91m'        # RED
BIGREEN='\033[1;92m'      # GREEN
BIYELLOW='\033[1;93m'     # YELLOW
BIBLUE='\033[1;94m'       # BLUE
BIPURPLE='\033[1;95m'     # PURPLE
BICYAN='\033[1;96m'       # CYAN
BIWHITE='\033[1;97m'      # WHITE

# HIGH INTENSITY BACKGROUNDS
ON_IBLACK='\033[0;100m'   # BLACK
ON_IRED='\033[0;101m'     # RED
ON_IGREEN='\033[0;102m'   # GREEN
ON_IYELLOW='\033[0;103m'  # YELLOW
ON_IBLUE='\033[0;104m'    # BLUE
ON_IPURPLE='\033[0;105m'  # PURPLE
ON_ICYAN='\033[0;106m'    # CYAN
ON_IWHITE='\033[0;107m'   # WHITE
" >> /bin/colors





touch /bin/make_dj_db
chmod +x /bin/make_dj_db
echo "
source /bin/colors

make_user(){
    echo \"Enter a password for \$NEW_DB_USER: \"
    read -s NEW_DB_PASS
    sudo -u postgres psql -tAc \"CREATE USER \$NEW_DB_USER WITH PASSWORD '\$NEW_DB_USER';\"
}

function assign_privs(){
    echo -e \"\${BYELLOW}Type Terms separated by spaces: \nmore at: https://www.postgresql.org/docs/9.1/static/sql-alterrole.html\n\${NIL}\"
    read -p \"Assign privilegs to \$NEW_DB_USER: \" -e -i \"SUPERUSER CREATEROLE CREATEDB REPLICATION\" NEW_DB_PRIV

    for PRIV in \$NEW_DB_PRIV; do
        sudo -u postgres psql -tAc \"ALTER USER \$NEW_DB_USER WITH \${PRIV^^};\"
    done
}

function assign_user_to_db(){
    read -p \"Assign \$NEW_DB_USER to a database: \" NEW_DB
    if [  -z \${NEW_DB+x} ]; then
        assign_user_to_db
    else
        sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw \$NEW_DB
        DB_MADE=\$?
        if [ \$DB_MADE == 1 ]; then
            sudo -u postgres psql -tAc \"CREATE DATABASE \$NEW_DB WITH OWNER \$NEW_DB_USER;\"
        fi
        sudo -u postgres psql -tAc \"GRANT ALL PRIVILEGES ON DATABASE \$NEW_DB to \$NEW_DB_USER;\"
    fi
}



function change_your_dir(){

    if [ ! -f \$PWD/settings.py ]; then
        echo -e \${RED}
        echo -e \" Select a project's \${BRED}main app folder\${RED} first!\n \${YELLOW}(where the \${BWHITE}settings.py\${YELLOW} file lives.\${NIL})\n\"
        echo -e \${NIL}
        read -e -i '/vagrant/www/' -p \"Enter location of your project's main app folder: \" CD_APP
        cd \$CD_APP
        if [ ! -f \$PWD/settings.py ]; then
            change_your_dir
        fi
    fi
}

function update_app_settings(){

    change_your_dir
    continue_update_app_settings
}


### CHECK PYTHON MODULES ARE INSTALLED ###
function check_module(){
    python -c \"import \${1}\" 2> /dev/null
    INSTALLED=\$?
    if [ \$INSTALLED == 1 ]; then
        echo -e \${BYELLOW}
        echo -e \${1} not found \${BGREEN}
        echo installing \${1}...
        echo -e \${NIL}
        pip install \${1}
        # echo -e \${BGREEN}\" \${successfully downloaded} # SHOULD _ACTUALLY_ check stderr to see if it DID successfully download!
    fi 
}

### CHECK LINUX PACKAGES ARE INSTALLED ###
function check_package(){
    dpkg -l \${1} &> /dev/null
    INSTALLED=\$?
    if [ \$INSTALLED == 1 ]; then
        echo -e \${BYELLOW}
        echo -e \${1} not found \${BGREEN}
        echo installing \${1}...
        echo -e \${NIL}
        apt-get install --upgrade -y \${1};
    fi
}

# for formatting the settings.py file.
check_module autopep8

### USER INPUT METHODS ###
function update_data()
{

    case \${1} in
        db_alias)
        if [ -z \${2+x} ]; then
            DB_ALIAS='default'
        else
            DB_ALIAS=\${2}
        fi
        echo -e \${BGREEN}using ALIAS: \$DB_ALIAS \${NIL}
        ;;
        engine)
        DB_ENGINE=\${2}
        if [ \${2} == 'postgresql' ]; then
            check_package postgresql
            check_package postgresql-client-common
            check_module psycopg2
        fi
        sed -i \"/^DATABASES/ {:loop n; /'\$DB_ALIAS/{:moop n; /'ENGINE':/{s/\s\+'ENGINE':.*/'ENGINE': 'django.db.backends.\${2}',/g}; t loop; /}/{s/\s\+}.*/'ENGINE': 'django.db.backends.\${2}',\\n },/}; t loop; b moop} ;b loop}\" settings.py
        autopep8 --in-place --aggressive --aggressive settings.py
        ;;
        name)
        DB_NAME=\${2}
        sed -i \"/^DATABASES/ {:loop n; /'\$DB_ALIAS'/{:moop n; /'NAME':/{s/\s\+'NAME':.*/'NAME': '\${2}',/g}; t loop; /}/{s/\s\+}.*/'NAME': '\${2}',\\n },/}; t loop; b moop} ;b loop}\" settings.py
        autopep8 --in-place --aggressive --aggressive settings.py
        ;;
        user)
        DB_USER=\${2}
        sed -i \"/^DATABASES/ {:loop n; /'\$DB_ALIAS'/{:moop n; /'USER':/{s/\s\+'USER':.*/'USER': '\${2}',/g}; t loop; /}/{s/\s\+}.*/'USER': '\${2}',\\n },/}; t loop; b moop} ;b loop}\" settings.py
        autopep8 --in-place --aggressive --aggressive settings.py
        ;;
        password)
        sed -i \"/^DATABASES/ {:loop n; /'\$DB_ALIAS'/{:moop n; /'PASSWORD':/{s/\s\+'PASSWORD':.*/'PASSWORD': '\${2}',/g}; t loop; /}/{s/\s\+}.*/'PASSWORD': '\${2}',\\n },/}; t loop; b moop} ;b loop}\" settings.py
        autopep8 --in-place --aggressive --aggressive settings.py
        ;;
        host)
        DB_HOST=\${2}
        sed -i \"/^DATABASES/ {:loop n; /'\$DB_ALIAS}'/{:moop n; /'HOST':/{s/\s\+'HOST':.*/'HOST': '\${2}',/g}; t loop; /}/{s/\s\+}.*/'HOST': '\${2}',\\n },/}; t loop; b moop} ;b loop}\" settings.py
        autopep8 --in-place --aggressive --aggressive settings.py
        ;;
        port)
        DB_PORT=\${2}
        sed -i \"/^DATABASES/ {:loop n; /'\$DB_ALIAS'/{:moop n; /'PORT':/{s/\s\+'PORT':.*/'PORT': '\${2}',/g}; t loop; /}/{s/\s\+}.*/'PORT': '\${2}',\\n },/}; t loop; b moop} ;b loop}\" settings.py
        autopep8 --in-place --aggressive --aggressive settings.py
        ;;
    esac

}



function continue_update_app_settings(){


    ### SELECTING THE DATABASE ALIAS ###
    echo -e \${BWHITE}
    read -e -i 'default' -p 'Enter the database ALIAS youd like to edit: ' THE_ALIAS

    # output to a temp file
    sed -n '/DATABASES*/,/# Password validation/p' settings.py >> tmp_alias_generator.txt
    # check if exact match exists.
    grep -Fxq \"    '\$THE_ALIAS': {\" tmp_alias_generator.txt
    ALIAS_EXISTS=\$?
    # create if it doesnt exist
    if [ \$ALIAS_EXISTS == 1 ]; then
        sed -i \"/DATABASES = {/{s/.*/DATABASES = {\n'\$THE_ALIAS': {\n},/}\" settings.py
        autopep8 --in-place --aggressive --aggressive settings.py

    fi

    update_data db_alias \$THE_ALIAS

    PS3=\"Select a database ENGINE for the ALIAS '\$DB_ALIAS': \"

    select db_engine in postgresql mysql sqlite3 oracle SKIP
    do
        case \$db_engine in
            postgresql)
            update_data engine \$db_engine
            break    
            ;;
            mysql)
            update_data engine \$db_engine
            break    
            ;;
            sqlite3)
            update_data engine \$db_engine
            break    
            ;;
            oracle)
            update_data engine \$db_engine
            break    
            ;;
            SKIP)
            echo -e \${YELLOW}Continuing...\${NIL}
            break
            ;;
            *)      
            echo 'Please select an option'
        esac 
    done

    ### DATABASE NAME
    enter_db_name(){
        read -e -i \"\$NEW_DB\" -p \"Database to connect to: \" DB_NAME
        if [ -z \${DB_NAME} ]; then
            echo -e \${RED}Invalid Input\${NIL}
            enter_db_name
        else
            update_data name \$DB_NAME
        fi
    }
    ### DATABASE USER
    enter_db_user(){
        read -e -i \"\$NEW_DB_USER\" -p \"Enter USER to connect to \$DB_NAME: \" DB_USER
        if [ -z \${DB_USER} ]; then
            echo -e \${RED}Invalid Input\${NIL}
            enter_db_user
        else
            update_data user \$DB_USER
        fi
    }
    ### DATABASE PASSWORD
    enter_db_pass(){
#        read -p \"Auto-import password? [y/n] \" prompt
#        if [[ \${prompt,,} =~ ^(yes|y)\$ ]]; then
#            update_data password \$NEW_DB_PASS
#        else
            echo \"Enter the PASSWORD for \$DB_USER: \"
            read -s DB_PASS
            if [ -z \${DB_PASS} ]; then
                echo -e \${RED}Invalid Input\${NIL}
                enter_db_pass
            else
                update_data password \$DB_PASS
            fi      
#        fi
    }
    ### DATABASE HOST
    enter_db_host(){
        read -e -i 'localhost' -p \"HOST for \$DB_NAME: \" DB_HOST
        if [ -z \${DB_HOST} ]; then
            echo -e \${RED}Invalid Input\${NIL}
            enter_db_host
        else
            update_data host \$DB_HOST
        fi
    }
    ### DATABASE PORT
    enter_db_port(){
        read -e -i '5432' -p \"PORT for \$DB_HOST: \" DB_PORT
        if [ -z \${DB_PORT} ]; then
            echo -e \${RED}Invalid Input\${NIL}
            enter_db_port
        else
            update_data port \$DB_PORT
        fi
    }

    ### EXECUTE QUESTION FUNCS.
    enter_db_name
    enter_db_user
    enter_db_pass
    enter_db_host
    enter_db_port

}



### RUN THE PROGRAM ###


read -p \"Database User: \" NEW_DB_USER
COMMAND=\"SELECT 1 FROM pg_roles WHERE rolname='\$NEW_DB_USER'\"
sudo -u postgres psql -tAc \"\$COMMAND\" | grep -q 1 || read -p \"Create New User? [y/n] \" prompt

if [[ \${prompt,,} =~ ^(yes|y)\$ ]]; then
    make_user
    COMMAND=\"SELECT 1 FROM pg_roles WHERE rolname='\$NEW_DB_USER'\"
    sudo -u postgres psql -tAc \"\$COMMAND\" | grep -q 0 || assign_privs
    assign_user_to_db
    update_app_settings
else
    COMMAND=\"SELECT 1 FROM pg_roles WHERE rolname='\$NEW_DB_USER'\"
    sudo -u postgres psql -tAc \"\$COMMAND\" | grep -q 0 || assign_user_to_db
    update_app_settings
fi" >> /bin/make_dj_db


# Reload system environment variables so they are immediately available.
source /etc/bash.bashrc
