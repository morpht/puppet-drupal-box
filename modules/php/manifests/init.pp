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
# [*php_apc_pkg*]
# The name of php_apc package to use. Default is php-fpm (ubuntu default).
# The dotdeb repo uses php5-apc.
#
# [*apc_shm_size*]
# How much memory to alocate for APC.
#
# [*apc_ttl*]
# apc.ttl: http://php.net/manual/en/apc.configuration.php#ini.apc.ttl
#
# [*apc_user_ttl*]
# apc.user_ttl: http://php.net/manual/en/apc.configuration.php#ini.apc.user-ttl
# If not specified (undef), it will be set to the same value as apc.ttl
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
# [*ensure_php_debug_pkgs*]
# whether to install php5-xdebug'
# Valid values are: present, installed, absent, purged
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
  $php_apc_pkg           = 'php-apc',
  $apc_ttl               = 0,
  $apc_user_ttl          = undef,
  $fpm_max_children      = 10,
  $fpm_start_servers     = 4,
  $fpm_min_spare_servers = 2,
  $fpm_max_spare_servers = 6,
  $ensure_php_debug_pkgs = 'purged'
) {

  if ! ($ensure_php_debug_pkgs in [ 'present', 'installed', 'absent', 'purged' ]) {
    fail('ensure_php_debug_pkgs parameter has wrong value')
  }

  # when one of the apc packages is in, the other needs to be absent:
  if $php_apc_pkg == 'php-apc' {
    $remove_apc_pkg = 'php5-apc'
  }
  elsif $php_apc_pkg == 'php5-apc' {
    $remove_apc_pkg = 'php-apc'
  }
  else {
    fail('php_apc_parameter needs to be php5-apc or php-apc')
  }

  # if $apc_user_ttl hasn't been defined, it makes sense to use the same value as $apc_ttl:
  $my_apc_user_ttl = $apc_user_ttl ? {
    undef   => $apc_ttl,
    default => $apc_user_ttl,
  }

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
    'php5-suhosin'
 ]:
      ensure  => installed,
  }
  package { $php_apc_pkg:
    ensure  =>  installed,
    require => Package[$remove_apc_pkg],
  }
  package { $remove_apc_pkg: ensure => purged }

  package { [
    'php5-xdebug'
 ]:
      ensure  => $ensure_php_debug_pkgs,
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
    require => Package[$php_apc_pkg],
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

