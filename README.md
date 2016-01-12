Server Setup Guide V1
=================

Initial version (V1) was written by Jin Cho on 1/9/2016.

This initial setup guide for the "ioboxes.local" developmental VM. Use this information to setup a new local development virtual machine. This guide is also used for setting up the ioboxes.com on data centers. 

The guide assumes that you have root access and is logged in as root. Otherwise, please use `sudo` command.



---



## I. CentOS 7 setup (version 7.2.1511)

Install CentOS on your VM or on server using Mimimum install of CentOS 7. 

   1.  See [Guide](https://www.rustprooflabs.com/2014/08/centos-7-vm) for installing it on VM if you are using VirtualBox. We are using VirtualBox 5.0.12 r104815 for this guide.

   2. Note that you have to choose a root password. Set any password you like, and memorize it. 

   3. It will also ask you if you want to create another user. Optionally, create a new user with name of your preference. In my case, I created `jcho`. If you did not create a user at installation, create one later when you setup **Samba**.

   4. Check the version of CentOS

      ```
      cat /etc/*-release
      ```

   5. Set Hostname

      ```
      echo $HOSTNAME

      # change the host name to "ioboxes"
      vi /etc/hostname
      ```
   6. Upgrade yum

      ```
      yum update && yum upgrade
      ```

   7. Install some tools

      ```
      yum install wget
      yum install epel-release
      yum install p7zip
      ```

   8. Optionally, Study basics of SELinux.

   9. Optionally, try out some basic network commands. If these commands are not installed, install them.

      ```
      # get current network status
      nmcli dev status

      # edit network configurations
      nmtui

      # restart network if any configurations were changed
      systemctl restart network

      # get ip addresses
      ip a s dev enp0s3 | grep inet
      ```
    
   10. Optionally, Install command line browser

        ```
        yum install links
        ```

   11. Optionally, play around with FirewallD. See more on [FirewallD Guide](http://www.tecmint.com/configure-firewalld-in-centos-7/)

        ```
        # systemctl status firewalld
        # firewall-cmd --list-ports
        # firewall-cmd --get-zones
        # firewall-cmd --zone=work --list-all
        # firewall-cmd --list-services
        # firewall-cmd --add-service=http
        # firewall-cmd --add-service=http --permanent
        # firewall-cmd --remove-service=http
        # firewall-cmd --zone=work --remove-service=http --permanent
        # firewall-cmd --add-port=331/tcp
        # firewall-cmd --add-port=331/tcp --permanent
        # firewall-cmd --remove-port=331/tcp
        # firewall-cmd --reload
        # firewall-cmd --remove-port=331/tcp --permanent
        # firewall-cmd --reload
        # systemctl stop firewalld
        # systemctl disable firewalld
        # systemctl enable firewalld
        # systemctl start firewalld
        ```

   12. Optionally, Install some networking tools

        ```
        yum install net-tools   
        yum install nmap
        nmap 127.0.0.1
       ```

   13. Optionally, install VirtualBox Guest Additions. Guides can be found on internet. Note that you need to install these first before installing VirtualBox Guest Addtions.

        ```
        sudo yum groupinstall "Development Tools"
        sudo yum install kernel-devel
        ```

        Mount the Virtualbox Additions CD ISO, and run setup command.

        ```
        sudo mkdir /media/cdrom/
        sudo mount /dev/cdrom /media/cdrom/
        sudo ./VBoxLinuxAdditions.running
        ```

   14. Optionally, install other useful tools. Refer to [Guide](http://www.tecmint.com/things-to-do-after-minimal-rhel-centos-7-installation/).

   15. Also, install SELinux tools. See [Guide](http://www.serverlab.ca/tutorials/linux/administration-linux/troubleshooting-selinux-centos-red-hat/)


        ```
        yum install setroubleshoot setools
        ```
---



## II. Configure VirtualBox networks interfaces.

   1. Open VirtualBox and make sure your guest VM is powered down.
   2. Go to VirtualBox  **File > Preferences > Network > Host-only Networks**
   3. You probably will not have any Host-only networks setup here. If you don't have one, add one. 
   4. Now close the Preferences and go to your VM's **Settings > Network**
   5. Set **Adaptor 1** to **NAT**.   
      This will be used for internet connection.
   6. Set **Adaptor 2** to **Bridged Adaptor**.  
      This will be used to connect to the whichever the host machine is connected to. 
   7. Set **Adaptor 3** to **Host-only Adaptor**.  
      This will be used for connecting from host machine to guest VM. 
   8. Turn on guest VM, and verify your network interfaces. You should see **enp0s3**, **enp0s8**, **enp0s9** and **lo**. 
      ```
      nmcli dev status
      ```
   9. Configure static IP address for enp0s9 which corresponds to Host-only adaptor you have configured. (Here, we are using static IP address **192.168.56.9**.) 

      ```
      nmtui 

      # This will open up a GUI.
      # Select "Wired Connection 1"
      # Go to "IPv4 CONFIGURATION" 
      # Add IP address as "192.168.56.9"
      # Save and exit and restart network service or reboot.
      systemctl restart network
      ```

    10. Finally, verify that ping works from your host machine to guest VM. If it does not work, [refer to this guide](https://www.rustprooflabs.com/2014/08/centos-7-vm) and fix it.

        ```
        # Ping from host machine to guest VM.
        ping -c4 192.168.56.9
        ```


---



## III. Configure hosts file

Add `192.168.56.9 ioboxes.local` to host machine's `etc/hosts` file.


```
# If using Mac OS, your host files are located at /private/etc/hosts
# The location of this file might be different for different OS.
# Add "192.168.56.9 ioboxes.local" to the file.
sudo vi /private/etc/hosts 
# Now verify that  ping works
ping -c4 ioboxes.local
```


---



## IV. Setup SSH and test connection

   - SSH should be enabled by default.
   - Test you connection from your host machine.
      ```
      # use the following command to connect.
      ssh root@ioboxes.local 
      # you can use "exit" command to disconnect.
      ```
   - If you are setting up a production server, make sure to take a look at the [Guide](http://www.tecmint.com/things-to-do-after-minimal-rhel-centos-7-installation/2/#C9), for more secure ssh setup.



---



## V. Create a project folder.

This is for your developmental use. We will later share this folder using samba.

```
mkdir /project
```


---



## VI. Setup Samba to share folders. 

For more information see [this guide](http://www.liberiangeek.net/2014/07/create-configure-samba-shares-centos-7/).

Also for `create mask` and `create directory mask`, take a look at [this guide](http://www.bodenzord.com/archives/53) 

   1. Backup original `smb.conf` file and create a new one.

      ```
      yum -y install samba samba-client samba-common
      mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
      vi /etc/samba/smb.conf
      ```
      `smb.conf` should have following lines.
      ```
      [global]
      workgroup = WORKGROUP
      server string = Samba Server %v
      netbios name =srvr1
      security = user
      map to guest = bad user
      dns proxy = no
   
      [allaccess]
      path = /samba/allaccess
      browsable = yes
      writable = yes
      guest ok = yes
      read only = no
   
      [project]
      path = /project
      valid users = jcho
      browsable = yes
      writable = yes
      guest ok = no

      ; below is there to give consistent outcome in both situations.
      ; 1. when you create a folder or file using shared folder access.
      ; 2. when you create a folder or file using user account via shell.

      create mask = 0664
      force create mode = 0000
      create directory mask = 0775
      force directory mode = 0020
      ```

   2. Start and enable the samba service

      ```
      systemctl start smb.service
      systemctl start nmb.service
      systemctl enable smb.service
      systemctl enable nmb.service
      # To restart
      # systemctl restart smb.service
      # systemctl restart nmb.service
      ```

   3. Configure `FirewallD`

      ```
      firewall-cmd --permanent --zone=public --add-service=samba
      firewall-cmd --reload
      ```

   4. Configure folders. This creates two folders if not exist. For `project` folder, replace `jcho` with your own user account you want to use.

      ```
      mkdir -p /samba/allaccess
      cd /samba
      chmod -R 0755 /samba/allaccess/
      chown -R nobody:nobody /samba/allaccess/
      chcon -t samba_share_t /samba/allaccess/
      mkdir -p /project
      groupadd securedgroup
      
      # Add securedgroup to your account 
      # If account does not exist, you can create and assign group by 
      # "useradd jcho -G securedgroup"
      usermod -a -G securedgroup jcho
      
      chmod -R 0777 /project/
      chown -R jcho:securedgroup /project/
      chcon -t samba_share_t /project/
      
      # Add Samba-specific password for your user.
      smbpasswd -a jcho
      ```

   5. Now verify that the shared folders are accessible.

      - To access `allaccess` folder. If you are using Mac OS, you can verify this by opening Finder and going to `Go > Connect to Server...`, and enter `smb://ioboxes.local/allaccess`. Try creating, editing and deleting files in the folder. It should all work.

      - To access `project` folder, use the address `smb://ioboxes.local/project`. This should ask you for your credentials. Enter in your user and samba password. Try creating, editing and deleting files in the folder. It should all work.



---



## VII. Nginx on CentOS 7 (version 1.6.3)

Run following lines of command.

```
sudo yum install epel-release
sudo yum install nginx
sudo systemctl start nginx

sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
sudo cp /etc/nginx/nginx.default.conf /etc/nginx/nginx.conf.default.bak


sudo firewall-cmd --permanent --zone=public --add-service=http 
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload
sudo systemctl enable nginx
```

The default server root directory is /usr/share/nginx/html. This location is specified in the default server block configuration file that ships with Nginx, which is located at /etc/nginx/conf.d/default.conf. Any additional server blocks, known as Virtual Hosts in Apache, can be added by creating new configuration files in /etc/nginx/conf.d. Files that end with .conf in that directory will be loaded when Nginx is started. The main Nginx configuration file is located at /etc/nginx/nginx.conf. See [Guide](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-centos-7)



---



## VIII. MySQL (MariaDB) in CentOS 7

1.  Run following lines of command. This will currently install version 5.5.44.
    ```
    sudo yum install mariadb-server mariadb
    sudo systemctl start mariadb
    sudo mysql_secure_installation
    sudo systemctl enable mariadb
    sudo firewall-cmd --zone=public --permanent --add-service=mysql
    sudo firewall-cmd --reload
    ```

    For more information see [this guide](https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-on-centos-7).

2. Now, let's upgrade MariaDB to 10. For more information, see [guide](https://mariadb.com/blog/installing-mariadb-10-centos-7-rhel-7).
    ```
    yum remove mariadb-server mariadb-libs
    ```

    Here is your custom MariaDB YUM repository entry for CentOS. 
    Copy and paste it into a file under /etc/yum.repos.d/ 
    (we suggest naming the file MariaDB.repo or something similar).

    ```
    # MariaDB 10.1 CentOS repository list - created 2016-01-04 17:52 UTC
    # http://mariadb.org/mariadb/repositories/
    [mariadb]
    name = MariaDB
    baseurl = http://yum.mariadb.org/10.1/centos7-amd64
    gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
    gpgcheck=1
    After the file is in place, install MariaDB with:
    ```

    Now, run following commands.

    ```
    sudo yum install MariaDB-server MariaDB-client
    /etc/init.d/mysql start
    mysql_upgrade -u root -p
    ```

    Now, check your version inside mysql.
    ```
    mysql -u root -p
    mysql> SHOW VARIABLES LIKE "%version%";
    ```
3. Also get used to these commands.

    ```
    mysql -u root -p
    show databases;
    use test;
    show tables;
    ```



---



## IX. Install PHP in CentOS 7 

1. Install using yum. This will install version 5.4.16. See [guide](https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-on-centos-7).

    ```
    sudo yum install php php-mysql php-fpm
    ```

2. Run `sudo vi /etc/php.ini` 

    Set `cgi.fix_pathinfo=0`. 

    Set the following as well. This sets server timezone. 

    ```
    [Date]
    ; Defines the default timezone used by the date functions
    ; http://php.net/date.timezone
    date.timezone = America/Los_Angeles
    ```

3. Run `sudo vi /etc/php-fpm.d/www.conf`. 

    Set `listen = /var/run/php-fpm/php-fpm.sock`. 

    Set `listen.owner = nobody` 

    Set `listen.group = nobody`. 
    
    Set `listen.mode = 0666`. (not sure why required but, it is required for php5.6 version). 

    Set `user = nginx` and `group = nginx`

4. Run `sudo systemctl start php-fpm && sudo systemctl enable php-fpm`.

5. Run `sudo vi /etc/nginx/conf.d/default.conf` then replace as below.

    ```
    server {
        listen       80;
        server_name  server_domain_name_or_IP;

        # note that these lines are originally from the "location /" block
        root   /usr/share/nginx/html;
        index index.php index.html index.htm;

        location / {
            try_files $uri $uri/ =404;
        }
        error_page 404 /404.html;
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
            root /usr/share/nginx/html;
        }

        location ~ \.php$ {
            try_files $uri =404;
            fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
    }
    ```

6. Run `sudo systemctl restart nginx`.

7. Run `sudo vi /usr/share/nginx/html/info.php`. 

   Then, enter `<?php phpinfo(); ?>`. 

   Visit `http://your_server_IP_address/info.php` to verify that php is configured.

8. Run `sudo rm /usr/share/nginx/html/info.php`.

---



## X. Upgrade to Nginx 1.8 and PHP 5.6 on CentOS 7 via Yum

Let's now upgrade the server to use PHP 5.6. 

See [guide](http://www.if-not-true-then-false.com/2011/install-nginx-php-fpm-on-fedora-centos-red-hat-rhel/). 

This guide also has information on how to setup server blocks (aka Virtual Hosts).

Note that this also upgrades Nginx.

Create `/etc/yum.repos.d/nginx.repo` file and add following lines.

```
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
```

```
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
yum --enablerepo=remi,remi-php56 install nginx php-fpm php-common

```

To test that the version is updated. let's do `<?php phpinfo()?>`. 

If you get error, debug it by looking at the log.

```
cat /var/log/nginx/error.log | grep crit
cat /var/log/nginx/error.log | grep error
```

You might have to set timezone. See [guide](http://stackoverflow.com/questions/16765158/date-it-is-not-safe-to-rely-on-the-systems-timezone-settings).

Install additional modules from the [guide](http://www.if-not-true-then-false.com/2011/install-nginx-php-fpm-on-fedora-centos-red-hat-rhel/). This guide also has information on how to setup server blocks (aka Virtual Hosts).



---



## XI. PhpMyAdmin Setup (4.4.15.2) - Optional

sudo yum install epel-release
sudo yum install phpmyadmin
sudo ln -s /usr/share/phpMyAdmin /usr/share/nginx/html
sudo systemctl restart php-fpm
http://server_domain_or_IP/phpMyAdmin



---



## XII. Setup project folder's permission

```
sudo mkdir -p /project/
sudo chown jcho:jcho /project/
sudo chmod 0775 /project/
chcon -t samba_share_t /project/
```

From this point on, it is important not to create or copy anything to the `/project/` folder when logged in as `root`.
If you do so, just make sure to edit owner to jcho:jcho and set appropriate permission.
(for file 0664, for directory 0775).



---



## XIII. Setup server block

See [guide](https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-server-blocks-on-centos-7).
You should not have to edit any permissions if you followed above steps

```
su jcho
mkdir -p /project/ioboxes/
echo "<?php echo \"Hello World\" ?>" > /project/ioboxes/index.php
sudo mkdir /etc/nginx/sites-available
sudo mkdir /etc/nginx/sites-enabled
```

Then edit config file.

```
sudo vi /etc/nginx/nginx.conf
```

Add these lines to the end of the http {} block:

```
include /etc/nginx/sites-enabled/*.conf;
server_names_hash_bucket_size 64;
sudo cp /etc/nginx/conf.d/default.conf /etc/nginx/sites-available/ioboxes.conf
```

Edit the newly created file

```
sudo vi /etc/nginx/sites-available/ioboxes.conf
```

Configure it. Finished file should look like this.

```
server {
    listen  80;

    server_name ioboxes.* www.ioboxes.*;

    location / {
        root  /project/ioboxes;
        index  index.html index.htm;
        try_files $uri $uri/ =404;
    }

    error_page  500 502 503 504  /50x.html;
    location = /50x.html {
        root  /usr/share/nginx/html;
    }
}
```

Now, enable the config

```
sudo ln -s /etc/nginx/sites-available/ioboxes.conf /etc/nginx/sites-enabled/ioboxes.conf
sudo systemctl restart nginx
```

Now edit `/etc/hosts`. Add `127.0.0.1 ioboxes.local`.

Now run `links http://ioboxes.local/` to see if you see "Hello".

You will see permission error (i.e. 403 forbidden error).

This is because document root should have a different SELinux type.
Let's use "public_content_rw_t" here for developemtal VM.
Look at the [guide](http://serverfault.com/questions/131105/how-do-i-get-selinux-to-allow-apache-and-samba-on-the-same-folder)

```
# this works for both samba and nginx.
# do not do this on production servers.
# in production servers, we should not 
# share a folder used as document root.
chcon -R -t public_content_rw_t /project/
setsebool -P allow_smbd_anon_write 1
setsebool -P allow_httpd_anon_write 1
```

Now, let's enable php on this server block.

```
server {
    listen  80;

    server_name ioboxes.local ioboxes.* www.ioboxes.*;

    root  /project/ioboxes;
    index  index.php index.html index.htm;
    location / {
        try_files $uri $uri/ =404;
    }

    error_page 404 /404.html;
    error_page  500 502 503 504  /50x.html;
    location = /50x.html {
        root  /usr/share/nginx/html;
    }
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

## XIV. Install PHP Framework Symphony 3.0.1

Install Composer

```
echo "Installing Composer globally..."
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/bin/composer
```

Install Symphony installer

```
sudo curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony
sudo chmod a+x /usr/local/bin/symfony
```

Create a new app

```
cd /project
mv /project/ioboxes /project/ioboxes_backup
symphony new ioboxes
chcon -R -t public_content_rw_t /project/
chmod 0775 ioboxes
```

Configure `/etc/nginx/sites-available/ioboxes.conf`
See [Guide](https://www.nginx.com/resources/wiki/start/topics/recipes/symfony/)

```
server {
    listen  80;

    server_name ioboxes.local ioboxes.* www.ioboxes.*;

    root  /project/ioboxes/web;
    error_log /var/log/nginx/ioboxes.error.log;
    access_log /var/log/nginx/ioboxes.access.log;

    # strip app.php/ prefix if it is present
    rewrite ^/app\.php/?(.*)$ /$1 permanent;

    location / {
        index app.php;
        try_files $uri @rewriteapp;
    }
    location @rewriteapp {
        rewrite ^(.*)$ /app.php/$1 last;
    }
    
    # pass the PHP scripts to FastCGI server from upstream phpfcgi
    location ~ ^/(app|app_dev|config)\.php(/|$) {
        fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param  HTTPS off;
    }
}
```

Also follow this step for var/cache and var/log errors.
See [guide](http://symfony.com/doc/current/book/installation.html#configuration-and-setup)

```
chmod 0777 /project/ioboxes/var/logs
chmod 0777 /project/ioboxes/var/cache
sudo setfacl -R -m u:nginx:rwX -m u:`whoami`:rwX /project/ioboxes/var/cache /project/ioboxes/var/logs
sudo setfacl -dR -m u:nginx:rwX -m u:`whoami`:rwX /project/ioboxes/var/cache /project/ioboxes/var/logs

```

For developmental server, make app_dev.php accessible by commenting out the below section.
See [this guide](https://www.digitalocean.com/community/tutorials/how-to-install-and-get-started-with-symfony-2-on-an-ubuntu-vps)

```
if (isset($_SERVER['HTTP_CLIENT_IP'])
    || isset($_SERVER['HTTP_X_FORWARDED_FOR'])
    || !in_array(@$_SERVER['REMOTE_ADDR'], array('127.0.0.1', 'fe80::1', '::1'))
) {
    header('HTTP/1.0 403 Forbidden');
    exit('You are not allowed to access this file. Check '.basename(__FILE__).' for more information.');
}
```


## XV. Create a sample controller and action for training purpose.

1. Copy DefaultController and play around with it.

    Also review how the permission is set on newly created files.

    If you are using mac, there might be `._*` files created in the background. 

    To fix this, run following command in the terminal.

    ```
    defaults write com.apple.desktopservices DSDontWriteNetworkStores true
    ```

    For more information [guide](http://www.cnet.com/news/invisible-files-with-prefix-are-created-on-some-shared-volumes-and-external-disks/)

2. Play around with controller generation commands. See [guide](http://symfony.com/doc/current/bundles/SensioGeneratorBundle/commands/generate_controller.html)

    ```
    php bin/console generate:controller
    ```

3. Also read this guide on [folder structures](http://symfony.com/doc/current/quick_tour/the_architecture.html)

4. Learn how to clear cache.

```
php bin/console cache:clear --env=prod
```

5. Learn about bundles. 

```
php bin/console generate:bundle --namespace=Foo/NewsBundle --format=yml
```

5. Learn about entity. See [guide](http://symfony.com/doc/current/book/doctrine.html)

6. Learn how to create CRUD controllers. Also see [guide](https://www.digitalocean.com/community/tutorials/how-to-use-symfony2-to-perform-crud-operations-on-a-vps-part-1)

```
php bin/console generate:doctrine:crud
```



## XVI. All-one-setup script `ioboxes.sh`

```
#!/bin/bash

# Usage 
# --upgrade (idempotent upgrade)
# --install (idempotent yum install everything)
# --checkout (checkout codebase)
# --log
# (/var/log/ioboxes/stdout.log)
# (/var/log/ioboxes/error.log)
# (/var/log/ioboxes/yum-list.log)
# (yum list installed > /tmp/yum-list.txt)
# must use sudo
# 

# Clear terminal.
clear

# CentOS Version Min and Max requirement

# Yum Upgrade

# Check CentOS version.

# Add user

# Install nginx

# Install mariadb

# Install php, php-fpm

# Install other libraries.





