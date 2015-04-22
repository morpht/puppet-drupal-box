# Puppet Drupal Box

## Description
Development server configuration managed using Puppet.
Currently for Ubuntu 14.04 LTS (trusty).

## Used components
-    varnish 3 (port 80)
-    apache 2.4  (port 8080) with mod_vhost_alias
-    php-fpm 5.5
-    percona server 5.5
-    memcached
-    drush 6.4
-    ntpdate (executed daily from cron)
-    postfix, delivering all mails (catch-all) to the 'localmail' user.

## Usage
Go to the VM or server you want to provision and run the following commands.

```
sudo apt-get update && sudo apt-get --yes install git
git clone git://github.com/morpht/puppet-drupal-box.git /tmp/puppet-drupal-box
sudo mv /tmp/puppet-drupal-box /opt/
cd /opt/puppet-drupal-box/
git submodule update --init

sudo puppet apply --modulepath=/opt/puppet-drupal-box/modules -e 'include drupal_sandbox'
```
This solution uses mod_vhost_alias, that means you can host multiple sites without reconfiguring apache.
The default VirtualDocumentRoot is "/srv/www/vhost/%0".
Say your dev site FQDN is drupal.example.com, your files go under /srv/www/vhost/drupal.example.com

If you want a different VirtualDocumentRoot, you can specify yours:
```
sudo puppet apply --modulepath=/opt/puppet-drupal-box/modules -e "class { 'drupal_sandbox': virtual_document_root => '/srv/www/%0' }"
```

## Vagrant
This project supports vagrant.
```
git clone https://github.com/morpht/puppet-drupal-box.git
cd puppet-drupal-box
vagrant up
```

## Notes
-   Find your mysql (randomly generated) root password in /etc/mysql/root-passwd.


-   For vagrant, use the "vhost" directory for your virtual hosts, they are mapped inside vagrant into the /srv/www/vhost

-   If not using vagrant up, create /srv/www/vhost/ inside your machine.

-   Parameters, especially memory settings for the services based on availale memory are under /opt/puppet-drupal-box/modules/drupal_sandbox/manifests/params.pp. Change as you need and run puppet apply again.

## Examples
Create info.example.com virtualhost with phpinfo(), inside your virtual machine:
```
sudo mkdir -p /srv/www/vhost/info.example.com
echo '<?php phpinfo(); ?>' > /tmp/index.php
sudo mv /tmp/index.php /srv/www/vhost/info.example.com/

```
Make info.example.com resolve to your virtual machine and point your browser at http://info.example.com

## Vagrant example
Create info.example.com virtualhost with phpinfo(), using the vhost directory:
```
mkdir info.example.com
echo '<?php phpinfo(); ?>' > info.example.com/index.php
```
Make info.example.com resolve to your virtual machine and point your browser at http://info.example.com

## Author
Marji Cermak <marji@morpht.com>
