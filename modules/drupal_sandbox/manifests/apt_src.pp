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

  # We want to get the region, e.g. us-west-1 or ap-southeast-2
  # but at least in AU, it returns ap-southeast-2b
  # so we need to cut of the character behind -digit, if any:
  if $::ec2_placement_availability_zone =~ /^(.+-\d)[a-z]{0,1}$/ {
    $archive = "http://${1}.ec2.archive.ubuntu.com/ubuntu/"
  } else {
    $archive = "http://us.archive.ubuntu.com/ubuntu/"
  }
  apt::source { 'precise':
    location   => $archive,
    release    => 'precise',
    repos      => 'main universe multiverse',
  }
  apt::source { 'precise-updates':
    location   => $archive,
    release    => 'precise-updates',
    repos      => 'main universe multiverse',
  }
  apt::source { 'precise-security':
    location   => 'http://security.ubuntu.com/ubuntu',
    release    => 'precise-security',
    repos      => 'main universe multiverse',
  }
  #
  # end of /etc/apt/sources.list replacement section

  apt::source { 'percona':
    location   => 'http://repo.percona.com/apt',
    repos      => 'main',
    key        => 'CD2EFD2A',
    key_server => 'keys.gnupg.net',
  }

}
