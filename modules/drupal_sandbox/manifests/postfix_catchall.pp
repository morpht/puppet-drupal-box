# == Class: drupal_sandbox::postfix_catchall
#
# This module installs postfix and configures it to deliver ALL emails
# to a single *local* mailbox.
#
# The mailbox file is weekly deleted to prevent overflow.
#
# === Parameters
#
# Document parameters here.
#
# [*catchall_user*]
#   A local user to deliver all emails to.
#
# === Authors
#
# Marji Cermak <marji@morpht.com>
#
class drupal_sandbox::postfix_catchall (
  $catchall_user = 'root',
  $manage_user   = false
) {

  # configure postfix to deliver locally and to one local mailbox:
  class { 'postfix':
    catchall_email => "${catchall_user}@localhost",
    catchall_only  => true,
  }

  if $manage_user {  
    user{ $catchall_user:
      ensure     => present,
      shell      => '/bin/bash',
      managehome => false,
    }
  }
  # delete the catchall mailbox weekly:
  file { '/etc/cron.weekly/discardmailbox':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
    content => "/bin/rm -f /var/mail/${catchall_user}\n",
  }
}
