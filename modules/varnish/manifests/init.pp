# Author: Marji Cermak <marji@morpht.com>
#
class varnish {

  package { 'varnish': ensure => installed }

  file { '/etc/varnish/default.vcl':
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/varnish/default.vcl',
    notify  => Service['varnish'],
    require => Package['varnish'],
  }

  file { '/etc/default/varnish':
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/varnish/varnish',
    notify  => Service['varnish'],
    require => Package['varnish'],
  }

  service { 'varnish': 
    enable   => true,
    ensure   => running,
    require  => Package['varnish'],
  }

}
