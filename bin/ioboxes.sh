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
elif [ "$1" = "commit" ]; then
    echo "Action: Commit"
    # change directory
    cd /project/ioboxes/
    git add . 
    git commit -m "$2"
    git push origin master
else
    echo "usage:"
    echo "- ioboxes upgrade: upgrade current ioboxes"
fi

