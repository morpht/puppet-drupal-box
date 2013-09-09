# == Class: postfix
#
# This class installs postfix. 
# For Debian based systems.
#
# === Details:
#
# This class install postfix and implements support for a localhost catch-all email address.
# If the catchall_email is defined, all email will be bcc-ed to that user.
# If catchall_only is set to true, all delivery will be local only and to that user only.
#
# === Parameters
#
# Document parameters here.
#
# [*inet_interfaces*]
#   Interface to listen on.
#   Default: loopback-only
#
# [*catchall_email*]
#   A local email address to deliver every single email to (regardless whether it's discarded or not).
#   Must be in form username@localhost (/etc/postfix/transport relies on localhost)
#
# [*catchall_only*]
#   Set it to true if you want postfix to deliver only locally
#     (i.e. discard everything which is not going to user@localhost)
#   Default: false
#
# === Examples
#
# class { 'postfix':
#   catchall_email => 'admin@localhost',
#   catchall_only  => true,
# }
#
# include postfix
#
# === Authors
#
# Marji Cermak <marji@morpht.com>
#
class postfix (
    $inet_interfaces = 'loopback-only',
    $catchall_email  = undef,
    $catchall_only   = false
) {


  if $catchall_only != true and $catchall_only != false {
    fail('postfix: catchall_only needs to be true of false (boolean, not string)')
  }
  if $catchall_only and !$catchall_email {
    fail('postfix: you requested catchall_only delivery, but did not provide a catchall_email to deliver all email to')
  }


  package { 'postfix':
    ensure => installed,
  }

  service { 'postfix':
    enable => true,
    ensure => running,
  }

  file { '/etc/postfix/main.cf':
    ensure  => present,
    content => template('postfix/main.cf.erb'),
    notify  => Service['postfix'],
    require => Package['postfix'],
  }

  file { '/etc/mailname':
    mode    => '0644',
    ensure  => present,
    content => "${fqdn}\n",
    notify  => Service['postfix'],
    require => Package['postfix'],
  }

  if $catchall_only {
    file { '/etc/postfix/transport':
      # not creating a file, for a one-liner:
      content  => "localhost :\n* discard:\n",
      require => Package['postfix'],
    }
    exec { 'create_transport_db':
      command     => '/usr/sbin/postmap /etc/postfix/transport',
      unless      => '/usr/bin/test -f /etc/postfix/transport.db',
      before      => File['/etc/postfix/main.cf'],
      require     => File['/etc/postfix/transport'],
    }
    exec { 'update_transport_db':
      command     => '/usr/sbin/postmap /etc/postfix/transport',
      subscribe   => File['/etc/postfix/transport'],
      refreshonly => true,
      notify      => Service['postfix'],
      require     => File['/etc/postfix/transport'],
    } 
  }
}
