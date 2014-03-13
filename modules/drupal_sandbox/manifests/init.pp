# == Class: drupal_sandbox
#
# This is a master module which install drupal sandbox.
# varnish - apache - php-fpm, memcached.
#
#
# === Variables
#
# [*virtual_document_root*]
# The desired VirtualDocumentRoot.
# Default value: "/srv/www/vhost/%0".
#
# [*php_memory_limit*]
# PHP memory_limit.
#
# === Authors
#
# Marji Cermak <marji@morpht.com>
#
class drupal_sandbox (
    $virtual_document_root = '/srv/www/vhost/%0',
    $php_memory_limit      = undef
) {

  include drupal_sandbox::params

  Exec { path => '/usr/bin:/bin:/usr/sbin:/sbin' }

  # Ensure apt sources are setup before installing any packages
  Apt::Source <| |> -> Package <| |>

  # Set up all apt sources:
  include drupal_sandbox::apt_src


  $the_php_memory_limit = $php_memory_limit ? {
    undef   => $drupal_sandbox::params::php_memory_limit,
    default => $php_memory_limit,
  }
  $memcache_mem              = $drupal_sandbox::params::memcache_mem
  $apc_mem                   = $drupal_sandbox::params::apc_mem

  $apache_port               = $drupal_sandbox::params::apache_port
  $apache_mpm_wk_max_clients = $drupal_sandbox::params::apache_mpm_wk_max_clients
  $fpm_max_children          = $drupal_sandbox::params::fpm_max_children
  $fpm_start_servers         = $drupal_sandbox::params::fpm_start_servers
  $fpm_min_spare_servers     = $drupal_sandbox::params::fpm_min_spare_servers
  $fpm_max_spare_servers     = $drupal_sandbox::params::fpm_max_spare_servers

  $innodb_buffer_pool_size   = $drupal_sandbox::params::innodb_buffer_pool_size
  $innodb_log_file_size      = $drupal_sandbox::params::innodb_log_file_size


  $mysqlpass                 = random_password(24)

  class { 'perconadb':
    password                => $mysqlpass,
    innodb_buffer_pool_size => $innodb_buffer_pool_size,
    innodb_log_file_size    => $innodb_log_file_size
  }

  class {'drush': }

  class {'php':
    php_engine            => 'php-fpm',
    memory_limit          => $the_php_memory_limit,
    apc_shm_size          => $apc_mem,
    fpm_max_children      => $fpm_max_children,
    fpm_start_servers     => $fpm_start_servers,
    fpm_min_spare_servers => $fpm_min_spare_servers,
    fpm_max_spare_servers => $fpm_max_spare_servers,
  }


  class { 'memcached':
    listen_ip  => '127.0.0.1',
    max_memory => $memcache_mem
  }

  class { 'ntpdate': }

  class { 'apache2':
    port               => $apache_port,
    mpm_wk_max_clients => $apache_mpm_wk_max_clients,
  }
  class { 'apache2::vhost_alias': 
    port                  => $apache_port,
    virtual_document_root => $virtual_document_root
  }


  include varnish


  # install postfix, set local email delivery to one central account:
  class { 'drupal_sandbox::postfix_catchall':
    catchall_user => 'localmail',
    manage_user   => true,
  }


}

