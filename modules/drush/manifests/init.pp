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
# class { 'drush': version => '5.10.0' }
# include drush
#
# === Authors
#
# Marji Cermak <marji@morpht.com>
#
# === History
#
#  - 2014/03/17 - changed source to github.com, relaying on the archive there,
#    as the drush project does not use ftp.drupal.org anymore

class drush ( $version = '6.2.0') {

  package { 'php-console-table':
     ensure => present,
  }

  exec { 'drush-retrieve':
    command => "wget https://github.com/drush-ops/drush/archive/${version}.tar.gz -O /tmp/drush-${version}.tar.gz",
    cwd     => "/tmp",
    creates => "/tmp/drush-${version}.tar.gz",
    path    => ['/bin', '/usr/bin'],
    unless  => "test -d /opt/drush-${version}",
  }

  exec { 'drush-untar':
    # github drush archives have version in the directory name, the transform is not needed:
    # command => "tar xzf /tmp/drush-${version}.tar.gz --transform s/drush/drush-${version}/ --no-same-owner",
    command => "tar xzf /tmp/drush-${version}.tar.gz --no-same-owner",
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
