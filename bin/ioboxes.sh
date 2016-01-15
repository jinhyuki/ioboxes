#!/bin/bash

if [ "$1" = "hello" ]; then
    echo "Action: Hello"
elif [ "$1" = "upgrade" ]; then
    echo "Action: Upgrade"
    # change directory
    cd /project/ioboxes/
    # get most recent update
    git pull
    # need to upgrade database
    php bin/console doctrine:schema:update --force
    # restart server
    sudo systemctl restart nginx && sudo systemctl restart php-fpm
else
    echo "usage:"
    echo "- ioboxes upgrade: upgrade current ioboxes"
fi

