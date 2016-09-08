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
  $memory_limit          = '96M',
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

  package { 'libapache2-mod-php5': ensure => purged }
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

  if $fpm_logrotate_when {
    file { '/etc/logrotate.d/php5-fpm':
      ensure  => present,
      content => template('php/logrotate.d/php5-fpm.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
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

