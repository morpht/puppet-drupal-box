apt-get update && apt-get -y install git
#
cd /opt/puppet-drupal-box/
git submodule update --init
# make puppet -drupal-box available under standard puppet modules directory
rmdir /etc/puppet/modules
ln -s /opt/puppet-drupal-box/modules /etc/puppet/modules
# provision the stack:
puppet apply -e 'include drupal_sandbox'
echo "upload your site to /srv/www/vhost/<YOUR_FQDN>"
echo "mysql root password is in: /etc/mysql/root-passwd"
