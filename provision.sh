apt-get update && apt-get -y install git
#
cd /opt/puppet-drupal-box/
# make puppet -drupal-box available under standard puppet modules directory
rmdir /etc/puppet/modules
ln -s /opt/puppet-drupal-box/modules /etc/puppet/modules
# provision the stack:
puppet apply -e 'include drupal_sandbox'

dversion='8.1.2'
echo "==== Installing Drush ${dversion}  ===="
mkdir /opt/drush-${dversion}
wget https://github.com/drush-ops/drush/releases/download/${dversion}/drush.phar -O /opt/drush-${dversion}/drush
chmod +x /opt/drush-${dversion}/drush
ln -snf /opt/drush-${dversion} /opt/drush


echo "upload your site to /srv/www/vhost/<YOUR_FQDN>"
echo "mysql root password is in: /etc/mysql/root-passwd"
