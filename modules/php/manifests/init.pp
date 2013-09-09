# == Class: php
# This class installs php. 
#
# === Details:
#
# === Parameters
#
# [*php_engine*]
#  What php engine to use.
#  Expected values: libapache2-mod-php5 or php5-fpm
#
# [*apc_shm_size*]
#  How much memory to alocate for APC.
#
# === Examples
#
# class { 'php': apc_shm_size => '128M' }
# include php
#
# === Authors
#
# Marji Cermak <marji@morpht.com>
#
class php (
  $php_engine = 'mod-php',
  $apc_shm_size = '64M'
) {

  case $php_engine {
    mod-php: { $php_engine_pkg = 'libapache2-mod-php5' }
    php-fpm: { $php_engine_pkg = 'php5-fpm' }
    default: { fail("Unrecognised php engine.") }
  }
  package { [
    'php5',
    $php_engine_pkg,
    'php-apc',
    'php-pear',
    'php5-cli',
    'php5-common',
    'php5-curl',
    'php5-gd',
    'php5-mcrypt',
    'php5-mysql',
    'php5-memcached',
    'php5-suhosin',
    'php5-xdebug',
    'php5-xhprof'
 ]:
      ensure  => installed,
  }

  if $php_engine == 'php-fpm' {

    service { 'php5-fpm':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      require    => Package['php5-fpm'],
      restart    => '/etc/init.d/php5-fpm reload',
      subscribe  => File['apc.ini', 'suhosin.ini' ],
    }

    file { '/etc/php5/fpm/pool.d/www.conf':
      ensure  => present,
      content => template('php/fpm/pool.d/www.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      notify  => Service['php5-fpm'],
      require => Package['php5-fpm'],
    }
  }

  file { 'apc.ini':
    path    => '/etc/php5/conf.d/apc.ini',
    ensure  => present,
    content => template('php/conf.d/apc.ini.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    require => Package['php-apc'],
  }

  file { 'suhosin.ini':
    path    => '/etc/php5/conf.d/suhosin.ini',
    ensure  => present,
    content => template('php/conf.d/suhosin.ini.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    require => Package['php5-suhosin'],
  }
}

