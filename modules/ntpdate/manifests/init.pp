# == Class: ntpdate
#
# This module installs ntpdate and schedules it to run daily.
#
#
# === Parameters
#
# [*servers*]
#   One or more ntp servers to use. Separated by space.
#
# [*run_daily*]
#   Whether to run ntpdate daily or not (true of false).
#
# === Authors
#
# Marji Cermak <marji@morpht.com>
#
class ntpdate($servers='ntp.ubuntu.com pool.ntp.org',
              $run_daily=true
) {

  if $run_daily == true {
    $cron_file_ensure = present
  } elsif $run_daily == false {
    $cron_file_ensure = absent
  } else {
    fail('run_daily parameter must be true of false')
  }

  package { 'ntpdate':
    ensure => present,
  }


  file { '/etc/cron.daily/ntpdate':
    ensure  => $cron_file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
    content => "[ -x /usr/sbin/ntpdate ] && /usr/sbin/ntpdate ${servers}\n",
  }
}
