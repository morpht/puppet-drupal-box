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
# [*memory_limit]
# PHP memory limit
#
# [*apc_shm_size*]
#  How much memory to alocate for APC.
#
# [*fpm_max_children*]
# pm.max_children for pool.d/www.conf. Only if php_engine is php5-fpm.
#
# [*fpm_start_servers*]
# pm.start_servers for pool.d/www.conf. Only if php_engine is php5-fpm.
#
# [*fpm_min_spare_servers*]
# pm.min_spare_servers for pool.d/www.conf. Only if php_engine is php5-fpm.
#
# [*fpm_max_spare_servers*]
# pm.max_spare_servers for pool.d/www.conf. Only if php_engine is php5-fpm.
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
  $php_engine            = 'mod-php',
  $memory_limit          = '96M',
  $apc_shm_size          = '64M',
  $fpm_max_children      = 10,
  $fpm_start_servers     = 4,
  $fpm_min_spare_servers = 2,
  $fpm_max_spare_servers = 6
) {

  case $php_engine {
    mod-php: { $php_engine_pkg = 'libapache2-mod-php5' }
    php-fpm: { $php_engine_pkg = 'php5-fpm' }
    default: { fail("Unrecognised php engine.") }
  }
  package { [
    'php5',
    $php_engine_pkg,
    'php-pear',
    'php5-cli',
    'php5-common',
    'php5-curl',
    'php5-gd',
    'php5-mcrypt',
    'php5-mysql',
    'php5-memcached',
    'php5-xdebug',
    'php5-xhprof'
 ]:
      ensure  => installed,
  }

  if $::lsbrelease == 'precise' {
    package { 'php5-apc':
      ensure  => installed,
    }
    package { 'php5-suhosin':
      ensure  => installed,
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

    # cli-php.ini needs the php5-suhosin package, but only on precise:
    Package['php5-suhosin'] -> File['cli-php.ini']

    # we want the php5-fpm to be notified on change
    # @todo: we should notify apache if we use libapache2-mod-php5
    if $php_engine == 'php-fpm' {
      File['suhosin.ini'] ~> Service['php5-fpm']
      File['apc.ini'] ~> Service['php5-fpm']
    }
  }

  if $php_engine == 'php-fpm' {

    service { 'php5-fpm':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      require    => Package['php5-fpm'],
      restart    => '/etc/init.d/php5-fpm reload',
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

}

