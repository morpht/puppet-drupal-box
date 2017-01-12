# == Class: apache2::log_perms
#
# Manages permissions on apache log directory and the logfiles.
# Ubuntu / Debian specific.
#
# === Details
#
# Existing logfiles get changed only if the /var/log/apache2 gets changed
# by puppet - very likely on the first run, but only if the dir's group/mode
# change is needded (refreshonly).
# All new logfiles get created from /etc/logrotate.d/apache2, which this
# submodule takes ownership of (setting the passed mode and group in it).
#
# === Variables
#
# [*log_group*]
# Desired group for /var/log/apache2 directory (and the logfiles in it).
# Default 'adm' (ubuntu default).
#
# [*logdir_mode*]
# Desired mode for /var/log/apache2 directory. Default '0750' (ubuntu default).
#
# [*logfiles_mode*]
# Desired mode of the logfiles. Default '0644'.
#
# === Examples
#
#  class { 'apache2::log_perms':
#    logdir_mode   => '0755',
#    logfiles_mode => '0644',
#  }
#
# === Authors
#
# Marji Cermak <marji@morpht.com>
#
class apache2::log_perms (
    $log_group     = 'adm',
    $logdir_mode   = '0750',
    $logfiles_mode = '0644',
) {

  require apache2

  file { '/var/log/apache2':
    ensure  => directory,
    mode    => $logdir_mode,
    group   => $log_group,
    require => Package['apache2'],
  }
  exec { 'logfiles-perms':
    command     => "find /var/log/apache2 -type f -exec chmod ${logfiles_mode} {} \; -exec chgr ${log_group} {} \;",
    subscribe   => File['/var/log/apache2'],
    refreshonly => true,
  }

  file { '/etc/logrotate.d/apache2' :
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('apache2/logrotate-apache2.erb'),
    require => Package['apache2'],
  }

}
