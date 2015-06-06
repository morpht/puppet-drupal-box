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
# class {'apache2': addr => '*', port => 8080 }
# include apache2
#
# === Authors
#
# Marji Cermak <marji@morpht.com>
#
class apache2 (
  $port                    = 80,
  $addr                    = '127.0.0.1',
  $log_level               = 'debug',
  $max_keep_alive_requests = 100,
  $mpm_wk_max_clients      = 150
) {

  package { [ 'apache2', 'libapache2-mod-fastcgi' ]:
    ensure => present,
  }

  # Enable modules needed for fastcgi php-fpm
  apache2::module { 'actions':     ensure => present }
  apache2::module { 'alias':       ensure => present }
  apache2::module { 'fastcgi':     ensure => present }
  apache2::module { 'rewrite':     ensure => present }
  apache2::module { 'headers':     ensure => present }
  apache2::module { 'expires':     ensure => present }
  apache2::module { 'vhost_alias': ensure => present }

  file { 'virtual-dir' :
    ensure => directory,
    path   => '/srv/www',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  file { '/srv/www/fastcgi' :
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  service { 'apache2':
    ensure   => running,
    enable   => true,
    require  => Package['apache2'],
  }

  #file { '/etc/apache2/apache2.conf' :
  #  ensure   => present,
  #  owner    => 'root',
  #  group    => 'root',
  #  mode     => '0444',
  #  content  => template('apache2/apache2.conf.erb'),
  #  require  => Package['apache2'],
  #  notify   => Service['apache2'],
  #}

  # if addr is '*', omit the addr part in listen:
  $listen_addr_port = $addr ? {
    '*'      => $port,
    default  => "${addr}:${port}",
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


  file { '/etc/apache2/sites-enabled/000-default.conf' :
    ensure   => absent,
    require  => Package['apache2'],
  }

}

