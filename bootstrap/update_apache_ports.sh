#!/bin/bash
source /bin/colors

function update_apache_ports(){
    echo -e "${BWHITE}Update Apache port ${CURRENT_PORT}?${NIL} [press ENTER to skip] : "
    read -p "Enter a Port Number to replace ${CURRENT_PORT}: " NEW_PORT
    valid='^[0-9]+$'

    if [ -z ${NEW_PORT} ]; then
        continue
    fi

    if ! [[ ${NEW_PORT} =~ $valid ]] ; then
       echo -e ${BRED}"Error: Please enter a valid value. ${NIL}"
       update_apache_ports
    else
        if [ ! -z ${NEW_PORT} ]; then
            sudo sed -i "s/\<Listen ${CURRENT_PORT}\>\s*/Listen ${NEW_PORT}/" /etc/apache2/ports.conf
            sudo sed -i "s/:${CURRENT_PORT}>/:${NEW_PORT}>/" /etc/apache2/sites-available/000-default.conf
            echo -e "${BGREEN}UPDATED PORT ${CURRENT_PORT} to ${NEW_PORT}!${NIL}"
        else
            echo -e "${BWHITE}skipped...${NIL}"
        fi
    fi
}

# RUN THE SCRIPT
# get Listening ports in file.
GET_APACHE_PORTS=$(sudo sed -n '/^Listen [0-9]*/p' /etc/apache2/ports.conf)
# remove "Listen" to create var with only Port #s.
AVAILABLE_PORTS=$(echo $GET_APACHE_PORTS | sed -e 's/\<Listen\>//g')
# store in an array.
AVAILABLE_PORTS_ARRAY=($AVAILABLE_PORTS)

for CURRENT_PORT in "${AVAILABLE_PORTS_ARRAY[@]}"
    do
        update_apache_ports
    done
# restart Apache to listen to new ports.
sudo /etc/init.d/apache2 restart