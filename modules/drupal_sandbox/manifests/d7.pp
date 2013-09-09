class drupal_sandbox::d7 (
    $drupal_version = '7.23',
    $docroot        = '/srv/www/www.example.com',
    $dbname         = 'example'
) {

  # need the dirname (www.example.com) for the drush parrameter --drupal-project-rename
  $dirname = regsubst($docroot,'^(.+)/(.+)$','\2')
  # the dir patch the dirname above gets created in (/srv/www)
  $dirpath = regsubst($docroot,'^(.+)/(.+)$','\1')

  exec {'drush-dl-drupal':
    command => "/usr/local/bin/drush dl drupal-$drupal_version --drupal-project-rename=$dirname",
    require => [ Class['drush'], File['/srv/www'], Class['perconadb'] ],
    cwd     => $dirpath,
    creates => $docroot,

  }
  exec {'drush-si':
#    command => '/usr/local/bin/drush -y si --db-url=mysql://root:$(cat /etc/mysql/root-passwd)@localhost/xoxo --account-name=admin --account-pass=admin --site-name="Your dev site"',
    command => "/usr/local/bin/drush -y si --db-url=mysql://root:$(cat /etc/mysql/root-passwd)@localhost/$dbname --account-name=admin --account-pass=admin --site-name='Your dev site'",
    cwd     => $docroot,
    logoutput => true,
    require => Exec['drush-dl-drupal'],
    unless  => "test -d $docroot/sites/default/files",
  }
  exec {'chmod-files':
    command => "/bin/chown -R www-data $docroot/sites/default/files",
    require => Exec['drush-si'],
    logoutput => true,
    unless  => "[ $(/usr/bin/find $docroot/sites/default/ -name files -user www-data -ls | /usr/bin/wc -l) != \"0\" ]",
  }
}

