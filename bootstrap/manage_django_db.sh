#/bin/bash
source /bin/colors
### CHECK PYTHON MODULES ARE INSTALLED ###
function check_module() {
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

### RUN THE PROGRAM ###

# for formatting the settings.py file.
check_module autopep8

PS3="Select A Database Engine to Use: "

    select db_engine in postgresql mysql sqlite3 oracle SKIP
    do
        case $db_engine in
            postgresql)
            sudo manage_django_db_postgres postgresql
            break 
            ;;
            mysql)
            echo -e ${BRED}"only postgres is currently supported!"${NIL}
            break    
            ;;
            sqlite3)
            echo -e ${BRED}"only postgres is currently supported!"${NIL}
            break    
            ;;
            oracle)
            echo -e ${BRED}"only postgres is currently supported!"${NIL}
            break    
            ;;
            *)      
            echo 'Please select an option'
        esac 
    done
