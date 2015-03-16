# == Class: apache2::vhost_alias
#
# Deploys a vhost, utilising mod_vhost.
#
# === Variables
#
# [*addr*]
# The IP address ov the virtual host.
#
# [*port*]
# The port for the vhost.
#
# [*virtual_document_root*]
# The VirtualDocumentRoot to use.
#
# [*fcgi_idle_timeout*]
# FastCGIExternalServer: idle-timeout
# http://www.fastcgi.com/mod_fastcgi/docs/mod_fastcgi.html#FastCgiExternalServer
#
# === Authors
#
# Marji Cermak <marji@morpht.com>
#
class apache2::vhost_alias (
    $addr                  = '127.0.0.1',
    $port                  = '80',
    $log_level             = 'debug',
    $virtual_document_root = '/srv/www/%0/docroot',
    $fcgi_idle_timeout     = 120
) {

  $vhost_name = 'vhost_alias'

  file { "/etc/apache2/sites-available/${vhost_name}" :
    ensure   => present,
    owner    => 'root',
    group    => 'root',
    mode     => '0444',
    content  => template('apache2/vhost_alias.erb'),
    require  => Package['apache2'],
    notify   => Service['apache2'],
  }

  exec { "/usr/sbin/a2ensite ${vhost_name}":
    path     => '/usr/bin:/usr/sbin:/bin',
    unless   => "test -L /etc/apache2/sites-enabled/${vhost_name}",
    notify   => Service['apache2'],
    require  => File["/etc/apache2/sites-available/${vhost_name}"],
  }

}

