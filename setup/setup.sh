#!/bin/bash

# switch user to eng account
function setup_login {
    # To create dev user if does not exist
    # id -u eng &>/dev/null || useradd eng 
    # need to set password
    su eng
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
    #sudo chcon -R -t usr_t /project/ioboxes/
    sudo chcon -R -h -t httpd_sys_content_t /project/ioboxes/
    #sudo setsebool -P allow_smbd_anon_write 1
    #sudo setsebool -P allow_httpd_anon_write 1
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

# Install utilities
function setup_utilities {
    sudo yum -y install git
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
    echo "Type In Samba Password"
    
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
    sudo yum remove php*
    sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
    sudo yum --enablerepo=remi,remi-php56 install php-fpm php-common php
    
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
    
    sudo mkdir -p /project/ioboxes/
    echo "<?php echo \"Hello World\" ?>" > /project/ioboxes/index.php
    
    sudo mkdir -p /etc/nginx/sites-available
    sudo mkdir -p /etc/nginx/sites-enabled

    #Add these lines to the end of the http {} block:
    # include /etc/nginx/sites-enabled/*.conf;
    # server_names_hash_bucket_size 64;    
    echo 'Later, you need to edit /etc/nginx/nginx.conf'
    read -n 1 -s

    sudo cp ./ioboxes.conf /etc/nginx/sites-available/
    sudo cp /etc/nginx/sites-available/ioboxes.conf /etc/nginx/sites-available/ioboxes.conf.bak
    sudo ln -s /etc/nginx/sites-available/ioboxes.conf /etc/nginx/sites-enabled/ioboxes.conf

    sudo systemctl start php-fpm && sudo systemctl enable php-fpm

    sudo systemctl restart nginx
    sudo systemctl restart php-fpm

    # try following command
    #links http://localhost/info.php
}

# Setup Symfony
function setup_symfony {
    echo "Installing Composer globally..."
    #mkdir -p ~/tmp
    #cd ~/tmp
    #sudo curl -sS https://getcomposer.org/installer | php
    #sudo mv composer.phar /usr/bin/composer
    
    sudo curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony
    sudo chmod a+x /usr/local/bin/symfony

    cd /project
    #mv /project/ioboxes /project/ioboxes_backup
    symfony new ioboxes
    #chmod 0775 ioboxes
}
