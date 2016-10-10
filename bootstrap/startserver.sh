#!/bin/bash
source /bin/colors

if [ ! -f $PWD/manage.py ]; then
        echo -e ${BRED}Navigate to a Django Project folder first!${NIL}
else
        sudo $PWD/bin/python manage.py runserver [::]:80
fi