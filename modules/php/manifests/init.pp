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
# whether to install php5-xdebug' and 'php5-xhprof'
# Valid values are: present, installed, absent, purged
#
# === Examples
#
# class { 'php': memory_limit => '128M' }
# include php
#
# === Authors
#
# Marji Cermak <marji@morpht.com>
#
class php (
  $php_engine            = 'mod-php',
  $memory_limit          = '96M',
  $fpm_max_children      = 10,
  $fpm_start_servers     = 4,
  $fpm_min_spare_servers = 2,
  $fpm_max_spare_servers = 6,
  $ensure_php_debug_pkgs = 'installed'
) {

  if ! ($ensure_php_debug_pkgs in [ 'present', 'installed', 'absent', 'purged' ]) {
    fail('ensure_php_debug_pkgs parameter has wrong value')
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
    'php5-memcached'
 ]:
      ensure  => installed,
  }

  package { [
    'php5-xdebug',
    'php5-xhprof'
 ]:
      ensure  => $ensure_php_debug_pkgs,
  }

  if $php_engine == 'php-fpm' {

    service { 'php5-fpm':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      require    => Package['php5-fpm'],
      provider   => upstart,
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

