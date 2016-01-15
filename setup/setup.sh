#!/bin/bash

# switch user to eng account
function setup_login {
    # To create dev user if does not exist
    # id -u eng &>/dev/null || useradd eng 
    # need to set password
    su eng

    # setup time zone
    sudo timedatectl set-timezone America/Los_Angeles
    sudo timedatectl
}

# set centos
function setup_centos {
    # setup time zone
    sudo timedatectl set-timezone America/Los_Angeles
    sudo timedatectl

    #selinux
    sudo setenforce 1
    sudo getenforce
}

# Setup firewall
function setup_firewall {
    sudo systemctl start firewalld
    sudo systemctl enable firewalld
}

# Create project directory
function setup_project {
    sudo mkdir -p /project/
    sudo chmod 0775 /project/
    sudo chown -R eng:eng /project/
    # Do this if you want to share project folder
    # Do not do this on production servers.
    #   sudo chcon -R -t samba_share_t /project/
    # To undo, do this.
    #   sudo chcon -R -t default_t /project/
    # If you want to share the folder and also 
    # serve php from the folder, do this.
    # sudo chcon -R -t public_content_rw_t /project/
    # sudo setsebool -P allow_smbd_anon_write 1
    # sudo setsebool -P allow_httpd_anon_write 1

    #sudo chcon -R -t usr_t /project/ioboxes/
    sudo chcon -R -h -t httpd_sys_content_t /project/
    
}

# Create ioboxes directory
function clone_ioboxes {
    cd /project
    git clone https://github.com/jinhyuki/ioboxes.git
    # Do this if you want to share project folder
    # Do not do this on production servers
    #   sudo chcon -R -t samba_share_t /project/ioboxes/
    # To undo 
    #   sudo chcon -R -t default_t /project/ioboxes/
    # If you want to share the folder and also 
    # serve php from the folder, do this.
    sudo chmod 0775 /project/ioboxes/
    # sudo chcon -R -t usr_t /project/ioboxes/
    sudo chcon -R -h -t httpd_sys_content_t /project/ioboxes/
    # sudo setsebool -P allow_smbd_anon_write 1
    # sudo setsebool -P allow_httpd_anon_write 1

    # keep setup folder secure
    sudo chcon -R -h -t default_t /project/ioboxes/setup/
    # sudo chmod 0775 /project/ioboxes/
}

# Update all package
# Do it at your own risk
function setup_update {
    sudo yum update && sudo yum upgrade
}

# Change hostname to "ioboxes"
# Do it at your own risk
function setup_hostname {
    sudo cp /etc/hostname /etc/hostname.bak
    echo 'ioboxes' | sudo tee /etc/hostname
}

# Install git
function setup_git {
    sudo yum -y install git

    # commands
    # git add .
    # git status
    # git commit -m "message"
    # git show-branch
    # git push origin master

}

# Install utilities
function setup_utilities {
    sudo yum -y install wget
    sudo yum -y install epel-release
    sudo yum -y install p7zip
    sudo yum -y install links
    sudo yum -y install net-tools
    sudo yum -y install nmap
    sudo yum -y install setroubleshoot setools
}

# Install Samba (disabled by default)
function setup_samba {
    sudo yum -y install samba samba-client samba-common
    sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
    sudo cp ./smb.conf /etc/samba/smb.conf
    
    sudo systemctl start smb.service
    sudo systemctl start nmb.service
    sudo systemctl restart smb.service
    sudo systemctl restart nmb.service
    sudo systemctl enable smb.service
    sudo systemctl enable nmb.service

    sudo firewall-cmd --permanent --zone=public --add-service=samba
    sudo firewall-cmd --reload
    
    # Add Samba-specific password for your user.
    echo "Type In Samba Password later via smbpasswd -a eng"
    read -n 1 -s
    
    # need to save smb password.
    # sudo smbpasswd -a eng

    ls -ldZ /project

    # disable it by default for better security
    sudo systemctl disable smb.service
    sudo systemctl disable nmb.service
}

function setup_mysql {
    sudo yum install mariadb-server
    sudo yum update
    sudo mysql_secure_installation
    sudo cp MariaDB.repo /etc/yum.repos.d/
    sudo yum remove mariadb-server mariadb-libs
    sudo yum install MariaDB-server MariaDB-client
    sudo /etc/init.d/mysql start
    sudo mysql_upgrade -u root -p
    sudo systemctl enable mariadb

    # Version 5.5.3 introduced "utf8mb4", which is recommended
    # collation-server     = utf8mb4_general_ci # Replaces utf8_general_ci
    # character-set-server = utf8mb4            # Replaces utf8
    # See [guide](http://symfony.com/doc/current/book/doctrine.html)
    sudo cp /etc/my.cnf.d/server.cnf /etc/my.cnf.d/server.cnf.bak
    echo 'Later, you need to edit /etc/my.cnf.d/server.cnf'
    read -n 1 -s
    sudo systemctl restart mariadb

    // Selinux setup (important)
    // See [guide](https://www.drupal.org/node/2110549)
    sudo setsebool -P httpd_can_network_connect_db on
    getsebool httpd_can_network_connect_db
}

function setup_nginx {
    sudo cp nginx.repo /etc/yum.repos.d/
    sudo yum -y install nginx
    sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
    sudo cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo firewall-cmd --permanent --zone=public --add-service=http 
    sudo firewall-cmd --permanent --zone=public --add-service=https
    sudo firewall-cmd --reload
}

# Setup PHP
function setup_php {
    # php 5.6
    
    # might want to remove php just in case.
    # sudo yum remove php*
    # However, list them all, and re-install them.

    sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
    sudo yum --enablerepo=remi,remi-php56 install php-fpm php-common php

    # since we removed all php packages, let's install everythings we need.
    sudo yum --enablerepo=remi,remi-php56 install php-xml php-pear php-opcache php-cli php-pdo php-xml php-gd php-mbstring php-mcrypt php-mysql
    
    # See [this guide](http://www.if-not-true-then-false.com/2011/install-nginx-php-fpm-on-fedora-centos-red-hat-rhel/) for modules

    echo 'Later, you need to edit /etc/php.ini'
    read -n 1 -s
    sudo cp /etc/php.ini /etc/php.ini.bak
    # sudo cp ./php.ini /etc/php.ini

    # Set `cgi.fix_pathinfo=0`. 
    # 
    # Set the following as well. This sets server timezone. 
    # 
    # ```
    # [Date]
    # ; Defines the default timezone used by the date functions
    # ; http://php.net/date.timezone
    # date.timezone = America/Los_Angeles
    # ```

    echo 'Later, you need to edit /etc/php-fpm.d/www.conf'
    read -n 1 -s
    sudo cp /etc/php-fpm.d/www.conf /etc/php-fpm.d/www.conf.bak
    # sudo cp ./www.conf /etc/php-fpm.d/www.conf
    #
    # Set `listen = /var/run/php-fpm/php-fpm.sock`. 
    # Set `user = nginx` and `group = nginx`
    # Also...
    # Option A:
    # Set `listen.owner = nobody` 
    # Set `listen.group = nobody`. 
    # Set `listen.mode = 0666`. (not sure why required but, it is required for php5.6 version). 
    # Option B:
    # Set `listen.owner = nginx` 
    # Set `listen.group = nginx`. 
    # Set `listen.mode = 0660`.
        
    sudo mkdir -p /etc/nginx/sites-available
    sudo mkdir -p /etc/nginx/sites-enabled

    # Add these lines to the end of the http {} block:
    # include /etc/nginx/sites-enabled/*.conf;
    # server_names_hash_bucket_size 64;    
    echo 'Later, you need to edit /etc/nginx/nginx.conf'
    read -n 1 -s

    sudo systemctl start php-fpm && sudo systemctl enable php-fpm
    sudo systemctl restart nginx && sudo systemctl restart php-fpm


}

# configure ioboxes directory and permissions
function config_ioboxes {
    # Copy ioboxes.conf file
    # See [Guide](https://www.nginx.com/resources/wiki/start/topics/recipes/symfony/)
    echo 'Later, you need to edit /etc/nginx/sites-available/ioboxes.conf'
    read -n 1 -s
    sudo cp ./ioboxes.conf /etc/nginx/sites-available/
    sudo cp /etc/nginx/sites-available/ioboxes.conf /etc/nginx/sites-available/ioboxes.conf.bak
    sudo ln -s /etc/nginx/sites-available/ioboxes.conf /etc/nginx/sites-enabled/ioboxes.conf

    # to fix the cache and log error. (500 internal server error)
    # See [guide](http://symfony.com/doc/current/book/installation.html#configuration-and-setup)
    rm -rf /project/ioboxes/var/cache/*
    rm -rf /project/ioboxes/var/logs/*
    chmod 0777 /project/ioboxes/var/logs
    chmod 0777 /project/ioboxes/var/cache
    chcon -R -t httpd_sys_rw_content_t /project/ioboxes/var/logs
    chcon -R -t httpd_sys_rw_content_t /project/ioboxes/var/cache

    setfacl -R -m u:nginx:rwX -m u:`whoami`:rwX /project/ioboxes/var/cache /project/ioboxes/var/logs
    setfacl -dR -m u:nginx:rwX -m u:`whoami`:rwX /project/ioboxes/var/cache /project/ioboxes/var/logs
    #getfacl /project/ioboxes/var/logs
    #getfacl /project/ioboxes/var/cache
    sudo systemctl restart nginx && sudo systemctl restart php-fpm

    # try following command
    # links http://localhost/

    # also try this in another terminal and try the url.
    # http://localhost/app_dev.php
    # tail -F /var/log/nginx/ioboxes.error.log
}

# Setup Symfony
function setup_symfony {
    echo "Installing Composer globally..."
    # mkdir -p ~/tmp
    # cd ~/tmp
    # sudo curl -sS https://getcomposer.org/installer | php
    # sudo mv composer.phar /usr/bin/composer
    
    sudo curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony
    sudo chmod a+x /usr/local/bin/symfony

    # cd /project
    # mv /project/ioboxes /project/ioboxes_backup
    # symfony new ioboxes
    # chmod 0775 ioboxes
    
    # Doctrine config
    # app/config/parameters.yml

    # Create db
    # php bin/console doctrine:database:create

    # Create entity
    # php bin/console doctrine:generate:entity
    
    # To generate getters and setters
    # See [guide](http://symfony.com/doc/current/book/doctrine.html)
    # php bin/console doctrine:generate:entities AppBundle/Entity/Product
    # php bin/console doctrine:generate:entities AppBundle
    # php bin/console doctrine:generate:entities Acme

    # Create schema
    # php bin/console doctrine:schema:update --force

    # Learn about migrations

    # Verify
    # mysql> show databases;
    # mysql> use ioboxes;
    # mysql> show columns from tb_product


    # copy and configure database
    # enter in 'database_user', 'database_password', 'secret'
    sudo mkdir -p /etc/ioboxes
    sudo cp ./parameters.yml /etc/ioboxes/parameters.yml
    echo 'Later, you need to edit /etc/ioboxes/parameters.yml'
    read -n 1 -s

    # security settings should be copied.
    sudo cp ./security.yml /etc/ioboxes/security.yml

}
