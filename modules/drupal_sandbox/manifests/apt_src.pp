# == Class: drupal_sandbox::apt_src
#
# This module installs all the needed apt sources for this project.
# It takes over /etc/apt/sources.list as we need multiverse repo enabled too.
#
# === Variables
#
# [*ec2_placement_availability_zone*]
#   If this fact exists, the precise archive URL will be derived from it, as
#   each AWS region has an ubuntu mirror at <region>.ec2.archive.ubuntu.com
#
# === Authors
#
# Marji Cermak <marji@morpht.com>
#
class drupal_sandbox::apt_src {


  # Though AWS takes good care of /etc/apt/sources.list
  # we need to populate it ourself, as we need the multiverse repo as well:
  #
  class { 'apt': purge_sources_list => true }

  if $::lsbdistcodename == '' {
    fail('drupal_sandbox::apt_src: expecting ::lsbdistcodename')
  }
  $codename = $::lsbdistcodename

  # We want to get the region, e.g. us-west-1 or ap-southeast-2
  # but at least in AU, it returns ap-southeast-2b
  # so we need to cut of the character behind -digit, if any:
  if $::ec2_placement_availability_zone =~ /^(.+-\d)[a-z]{0,1}$/ {
    $archive = "http://${1}.ec2.archive.ubuntu.com/ubuntu/"
  } else {
    $archive = "http://us.archive.ubuntu.com/ubuntu/"
  }
  apt::source { $codename:
    location   => $archive,
    release    => $codename,
    repos      => 'main universe multiverse',
  }
  apt::source { "${codename}-updates":
    location   => $archive,
    release    => "${codename}-updates",
    repos      => 'main universe multiverse',
  }
  apt::source { "${codename}-security":
    location   => 'http://security.ubuntu.com/ubuntu',
    release    => "${codename}-security",
    repos      => 'main universe multiverse',
  }
  #
  # end of /etc/apt/sources.list replacement section

  apt::source { 'percona':
    location   => 'http://repo.percona.com/apt',
    repos      => 'main',
    key        => '1C4CBDCDCD2EFD2A',
    key_server => 'keyserver.ubuntu.com',
  }

  # only for precise, we use dotdeb repo:
  if $codename == 'precise' {
    apt::source { 'dotdeb':
      location   => 'http://packages.dotdeb.org',
      release    => 'squeeze',
      repos      => 'all',
      key        => '89DF5277',
      key_source => 'http://www.dotdeb.org/dotdeb.gpg',
    }
  }
}
