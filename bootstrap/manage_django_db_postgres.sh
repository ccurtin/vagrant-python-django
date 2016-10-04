#!/bin/bash
source /bin/colors

### CHECK PYTHON MODULES ARE INSTALLED ###
function check_module(){
    python -c "import ${1}" 2> /dev/null
    INSTALLED=$?
    if [ $INSTALLED == 1 ]; then
        echo -e ${BYELLOW}
        echo -e ${1} not found ${BGREEN}
        echo installing ${1}...
        echo -e ${NIL}
        pip install ${1}
        # echo -e ${BGREEN}" ${successfully downloaded} # SHOULD _ACTUALLY_ check stderr to see if it DID successfully download!
    fi 
}

### CHECK LINUX PACKAGES ARE INSTALLED ###
function check_package(){
    dpkg -l ${1} &> /dev/null
    INSTALLED=$?
    if [ $INSTALLED == 1 ]; then
        echo -e ${BYELLOW}
        echo -e ${1} not found ${BGREEN}
        echo installing ${1}...
        echo -e ${NIL}
        sudo apt-get install --upgrade -y ${1};
    fi
}


function change_your_dir(){

    if [ ! -f $PWD/settings.py ]; then
        echo -e ${RED}
        echo -e " Select a project's ${BRED}main app folder${RED} first!\n ${YELLOW}(where the ${BWHITE}settings.py${YELLOW} file lives.${NIL})\n"
        echo -e ${NIL}
        read -e -i '/vagrant/www/' -p "Enter location of your project's main app folder: " CD_APP
        cd $CD_APP
        if [ ! -f $PWD/settings.py ]; then
            change_your_dir
        fi
    fi
}


function make_user(){
    echo "Enter a password for $NEW_DB_USER: "
    read -s NEW_DB_PASS
    sudo -u postgres psql -tAc "CREATE USER $NEW_DB_USER WITH PASSWORD '$NEW_DB_PASS';"
}

function assign_privs(){
    echo -e "${BYELLOW}Type Terms separated by spaces: \nmore at: https://www.postgresql.org/docs/9.1/static/sql-alterrole.html\n${NIL}"
    read -p "Assign privilegs to $NEW_DB_USER: " -e -i "SUPERUSER CREATEROLE CREATEDB REPLICATION" NEW_DB_PRIV

    for PRIV in $NEW_DB_PRIV; do
        sudo -u postgres psql -tAc "ALTER USER $NEW_DB_USER WITH ${PRIV^^};"
    done
}

function assign_user_to_db(){
    read -p "Assign $NEW_DB_USER to a database: " NEW_DB
    if [  -z ${NEW_DB+x} ]; then
        assign_user_to_db
    else
        sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw $NEW_DB
        DB_MADE=$?
        if [ $DB_MADE == 1 ]; then
            sudo -u postgres psql -tAc "CREATE DATABASE $NEW_DB WITH OWNER $NEW_DB_USER;"
        fi
        sudo -u postgres psql -tAc "GRANT ALL PRIVILEGES ON DATABASE $NEW_DB to $NEW_DB_USER;"
    fi
}

function configure_md5_login(){
    echo -e ${BYELLOW}Update password for user "postgres"${NIL}
    # Create a new password for user "postgres"
    sudo -u postgres psql -tAc "\password postgres"
    sudo sed -i "s/\s*local\s*all\s*all\s*peer/local                  all               all                   md5/" /etc/postgresql/9.3/main/pg_hba.conf
    sudo service postgresql restart
}

function update_app_settings(){

    change_your_dir
    continue_update_app_settings ${1}
    configure_md5_login
}

### USER INPUT METHODS ###
function update_data(){

    case ${1} in
        db_alias)
        if [ -z ${2+x} ]; then
            DB_ALIAS='default'
        else
            DB_ALIAS=${2}
        fi
        echo -e ${BGREEN}using ALIAS: $DB_ALIAS ${NIL}
        ;;
        engine)
        sed -i "/^DATABASES/ {:loop n; /'$DB_ALIAS'/{:moop n; /'ENGINE':/{s/\s\+'ENGINE':.*/'ENGINE': 'django.db.backends.postgresql',/g}; t loop; /}/{s/\s\+}.*/'ENGINE': 'django.db.backends.postgresql',\\n },/}; t loop; b moop} ;b loop}" settings.py
        autopep8 --in-place --aggressive --aggressive settings.py
        ;;
        name)
        DB_NAME=${2}
        sed -i "/^DATABASES/ {:loop n; /'$DB_ALIAS'/{:moop n; /'NAME':/{s/\s\+'NAME':.*/'NAME': '${2}',/g}; t loop; /}/{s/\s\+}.*/'NAME': '${2}',\\n },/}; t loop; b moop} ;b loop}" settings.py
        autopep8 --in-place --aggressive --aggressive settings.py
        ;;
        user)
        DB_USER=${2}
        sed -i "/^DATABASES/ {:loop n; /'$DB_ALIAS'/{:moop n; /'USER':/{s/\s\+'USER':.*/'USER': '${2}',/g}; t loop; /}/{s/\s\+}.*/'USER': '${2}',\\n },/}; t loop; b moop} ;b loop}" settings.py
        autopep8 --in-place --aggressive --aggressive settings.py
        ;;
        password)
        sed -i "/^DATABASES/ {:loop n; /'$DB_ALIAS'/{:moop n; /'PASSWORD':/{s/\s\+'PASSWORD':.*/'PASSWORD': '${2}',/g}; t loop; /}/{s/\s\+}.*/'PASSWORD': '${2}',\\n },/}; t loop; b moop} ;b loop}" settings.py
        autopep8 --in-place --aggressive --aggressive settings.py
        ;;
        host)
        DB_HOST=${2}
        sed -i "/^DATABASES/ {:loop n; /'$DB_ALIAS'/{:moop n; /'HOST':/{s/\s\+'HOST':.*/'HOST': '${2}',/g}; t loop; /}/{s/\s\+}.*/'HOST': '${2}',\\n },/}; t loop; b moop} ;b loop}" settings.py
        autopep8 --in-place --aggressive --aggressive settings.py
        ;;
        port)
        DB_PORT=${2}
        sed -i "/^DATABASES/ {:loop n; /'$DB_ALIAS'/{:moop n; /'PORT':/{s/\s\+'PORT':.*/'PORT': '${2}',/g}; t loop; /}/{s/\s\+}.*/'PORT': '${2}',\\n },/}; t loop; b moop} ;b loop}" settings.py
        autopep8 --in-place --aggressive --aggressive settings.py
        ;;
    esac


}



function continue_update_app_settings(){

    ### SELECTING THE DATABASE ALIAS ###
    echo -e ${BWHITE}
    read -e -i 'default' -p 'Enter the database ALIAS youd like to edit: ' THE_ALIAS

    # output to a temp file
    sed -n '/DATABASES*/,/# Password validation/p' settings.py >> tmp_alias_generator.txt
    # check if exact match exists.
    grep -Fxq "    '$THE_ALIAS': {" tmp_alias_generator.txt
    ALIAS_EXISTS=$?
    # create if it doesnt exist
    if [ $ALIAS_EXISTS == 1 ]; then
        sed -i "/DATABASES = {/{s/.*/DATABASES = {\n'$THE_ALIAS': {\n},/}" settings.py
        autopep8 --in-place --aggressive --aggressive settings.py

    fi

    update_data db_alias $THE_ALIAS
    update_data engine postgres
    ### DATABASE NAME
    function enter_db_name(){
        read -e -i "$NEW_DB" -p "Database to connect to: " DB_NAME
        if [ -z ${DB_NAME} ]; then
            echo -e ${RED}Invalid Input${NIL}
            enter_db_name
        else
            update_data name $DB_NAME
        fi
    }
    ### DATABASE USER
    function enter_db_user(){
        read -e -i "$NEW_DB_USER" -p "Enter USER to connect to $DB_NAME: " DB_USER
        if [ -z ${DB_USER} ]; then
            echo -e ${RED}Invalid Input${NIL}
            enter_db_user
        else
            update_data user $DB_USER
        fi
    }
    ### DATABASE PASSWORD
    function enter_db_pass(){
    #        read -p "Auto-import password? [y/n] " prompt
    #        if [[ ${prompt,,} =~ ^(yes|y)$ ]]; then
    #            update_data password $NEW_DB_PASS
    #        else
    echo "Enter the PASSWORD for $DB_USER: "
    read -s DB_PASS
    if [ -z ${DB_PASS} ]; then
        echo -e ${RED}Invalid Input${NIL}
        enter_db_pass
    else
        update_data password $DB_PASS
    fi      
    #        fi
    }
    ### DATABASE HOST
    function enter_db_host(){
        read -e -i 'localhost' -p "HOST for $DB_NAME: " DB_HOST
        if [ -z ${DB_HOST} ]; then
            echo -e ${RED}Invalid Input${NIL}
            enter_db_host
        else
            update_data host $DB_HOST
        fi
    }
    ### DATABASE PORT
    function enter_db_port(){
        read -e -i '5432' -p "PORT for $DB_HOST: " DB_PORT
        if [ -z ${DB_PORT} ]; then
            echo -e ${RED}Invalid Input${NIL}
            enter_db_port
        else
            update_data port $DB_PORT
        fi
    }

    ### EXECUTE QUESTION FUNCS.
    enter_db_name
    enter_db_user
    enter_db_pass
    enter_db_host
    enter_db_port

}

### RUN THE SETUP ###

# installed required dependencies
check_package postgresql-9.3
check_package postgresql-client-common
check_package libpq-dev
# is needed to compile Python extension written in C ot C++, ie: psycopg2
# JUST INSTALL THIS TOO FOR NOW! EVENTUALLY NEED TO FIX THIS.
# check_package python3-dev
# USER MAY NEED A DIFFERENT VERSION OF python-dev, ie: 'python3.4-dev'
check_package python-dev
check_module psycopg2
check_package python-psycopg2
# Setup user and privs, 
read -p "Database User: " NEW_DB_USER
COMMAND="SELECT 1 FROM pg_roles WHERE rolname='$NEW_DB_USER'"
sudo -u postgres psql -tAc "$COMMAND" | grep -q 1 || read -p "Create New User? [y/n] " prompt

if [[ ${prompt,,} =~ ^(yes|y)$ ]]; then
    make_user
    COMMAND="SELECT 1 FROM pg_roles WHERE rolname='$NEW_DB_USER'"
    sudo -u postgres psql -tAc "$COMMAND" | grep -q 0 || assign_privs
    assign_user_to_db
    update_app_settings ${1}
else
    COMMAND="SELECT 1 FROM pg_roles WHERE rolname='$NEW_DB_USER'"
    sudo -u postgres psql -tAc "$COMMAND" | grep -q 0 || assign_user_to_db
    update_app_settings ${1}
fi