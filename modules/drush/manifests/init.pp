# == Class: drush
#
# This class installs Drush. 
# For Debian based systems due to the php-console-table package dependency.
#
# === Details:
#
# It downloads a drush tarball and extracts it under /opt/drush-VERSION
# and symlinks as /opt/drush.
# It also symlinks /usr/local/bin/drush to /opt/drush/drush
#
# It installs package php-console-table
#
# === Requires:
#
# Binaries: wget, tar
# Packages: php-console-table
#
# === Examples
#
# class { 'drush': version => '7.x-5.9' }
# include drush
#
# === Authors
#
# Marji Cermak <marji@morpht.com>
#

class drush ( $version = '7.x-5.9') {

  package { 'php-console-table':
     ensure => present,
  }

  exec { 'drush-retrieve':
    command => "wget http://ftp.drupal.org/files/projects/drush-${version}.tar.gz",
    cwd     => "/tmp",
    creates => "/tmp/drush-${version}.tar.gz",
    path    => ['/bin', '/usr/bin'],
    unless  => "test -d /opt/drush-${version}",
  }

  exec { 'drush-untar':
    command => "tar xzf /tmp/drush-${version}.tar.gz --transform s/drush/drush-${version}/ --no-same-owner",
    cwd     => '/opt',
    creates => "/opt/drush-${version}",
    path    => ['/bin', '/usr/bin'],
    require => Exec['drush-retrieve'],
  }

  file { '/opt/drush':
    ensure  => link,
    target  => "drush-${version}",
    require => Exec['drush-untar'],
    replace => true,
  }

  file { '/usr/local/bin/drush':
    ensure  => link,
    target  => '/opt/drush/drush',
    require => File['/opt/drush'],
  }

}
