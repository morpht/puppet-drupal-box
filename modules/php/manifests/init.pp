# == Class: php
# This class installs php.
#
# === Details:
#
# === Parameters
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
# pm.max_children for pool.d/www.conf.
#
# [*fpm_start_servers*]
# pm.start_servers for pool.d/www.conf.
#
# [*fpm_min_spare_servers*]
# pm.min_spare_servers for pool.d/www.conf.
#
# [*fpm_max_spare_servers*]
# pm.max_spare_servers for pool.d/www.conf.
#
# [*fpm_logrotate_when*]
# If it is not undef, /etc/logrotate.d/php will be created and the value
# will be used as frequency / condition.
# Example: weekly, daily, size 100k
#
# [*fpm_logrotate_rotate*]
# Used only if fpm_logrotate_when above is defined.
# How many log files to keep.
#
# [*php_error_log_path*]
# Full path of a logfile for php error logs - output from php5-fpm workers.
# It must not be the same file as /var/log/php5-fpm.log which belongs to
# the php5-fpm service / daemon itself (which runs as root while workers
# run as www-data, they also have different timestamp format).
#
# [*php_error_log_mode*]
# File mode of the php error log file.
#
# [*php_error_log_owner*]
# File owner of the php error log file.
#
# [*php_error_log_group*]
# Group owner of the php error log file.
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
  $memory_limit          = '96M',
  $apc_shm_size          = '64M',
  $php_apc_pkg           = 'php-apc',
  $apc_ttl               = 0,
  $apc_user_ttl          = undef,
  $fpm_max_children      = 10,
  $fpm_start_servers     = 4,
  $fpm_min_spare_servers = 2,
  $fpm_max_spare_servers = 6,
  $fpm_logrotate_rotate  = 12,
  $fpm_logrotate_when    = 'weekly',
  $php_error_log_path    = '/var/log/php5-errors.log',
  $php_error_log_mode    = '0640',
  $php_error_log_owner   = 'www-data',
  $php_error_log_group   = 'www-data',
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

  package { [
    'php5',
    'php5-fpm',
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
  if $fpm_logrotate_when {
    $reopenlogs = '/usr/local/bin/php5-fpm-reopenlogs'
    file { 'php5-fpm-reopenlogs':
      ensure  => present,
      path    => $reopenlogs,
      source  => 'puppet:///modules/php/php5-fpm-reopenlogs',
      owner   => 'root',
      group   => 'root',
      mode    => '0555',
    }
    file { '/etc/logrotate.d/php5-fpm':
      ensure  => present,
      content => template('php/logrotate.d/php5-fpm.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      require => File['php5-fpm-reopenlogs'],
    }
  }
  file { 'php_error_log':
    ensure  => file,
    path    => $php_error_log_path,
    owner   => $php_error_log_owner,
    group   => $php_error_log_group,
    mode    => $php_error_log_mode,
    require => Package['php5-fpm'],
    notify  => Service['php5-fpm'],
  }
}

