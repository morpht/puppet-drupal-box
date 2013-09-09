# == Class: apache2
#
# This class installs apache.
# It implements virtual server utilising fastcgi / php-fpm
# For Debian based systems.
#
# === Details:
#
# It provisions apache on port 80 by default, but port
# can be specified when used as a class.
#
# === Requires:
#
# php5-fpm
#
# === Examples
#
# class {'apache2': port => 8080 }
# include apache2
#
# === Authors
#
# Marji Cermak <marji@morpht.com>
#
class apache2 ( $port = 80 ) {

  package { [ 'apache2', 'libapache2-mod-fastcgi' ]:
    ensure => present,
  }

  # Enable modules needed for fastcgi php-fpm
  apache2::module { 'actions': ensure => present } 
  apache2::module { 'alias': ensure => present } 
  apache2::module { 'fastcgi': ensure => present } 
  apache2::module { 'rewrite': ensure => present } 
  apache2::module { 'vhost_alias': ensure => present } 

  file { 'virtual-dir' :
    path   => '/srv/www',
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  service { 'apache2':
    enable   => true,
    ensure   => running,
    require  => Package['apache2'],
  }

  file { '/etc/apache2/apache2.conf' :
    ensure   => present,
    owner    => 'root',
    group    => 'root',
    mode     => '0444',
    content  => template('apache2/apache2.conf.erb'),
    require  => Package['apache2'],
    notify   => Service['apache2'],
  }

  file { '/etc/apache2/ports.conf' :
    ensure   => present,
    owner    => 'root',
    group    => 'root',
    mode     => '0444',
    content  => template('apache2/ports.conf.erb'),
    require  => Package['apache2'],
    notify   => Service['apache2'],
  }

  # Good practice, there were troubles when the 'ServerName' was not defined.
  file { '/etc/apache2/conf.d/fqdn' :
    ensure   => present,
    owner    => 'root',
    group    => 'root',
    mode     => '0644',
    content  => "ServerName localhost\n",
    require  => Package['apache2'],
  }

  file { '/etc/apache2/sites-enabled/000-default' :
    ensure   => absent,
    require  => Package['apache2'],
  }

}

