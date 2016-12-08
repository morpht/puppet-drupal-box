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
# [*use_varnish*]
# Whether to install and use varnish.
#
# === Authors
#
# Marji Cermak <marji@morpht.com>
#
class drupal_sandbox (
    $virtual_document_root     = '/srv/www/vhost/%0',
    $use_varnish               = false,
    $php_memory_limit          = $drupal_sandbox::params::php_memory_limit,
    $apache_addr               = $drupal_sandbox::params::apache_addr,
    $apache_port               = $drupal_sandbox::params::apache_port,
    $memcache_mem              = $drupal_sandbox::params::memcache_mem,
    $apache_mpm_wk_max_clients = $drupal_sandbox::params::apache_mpm_wk_max_clients,
    $fpm_max_children          = $drupal_sandbox::params::fpm_max_children,
    $fpm_start_servers         = $drupal_sandbox::params::fpm_start_servers,
    $fpm_min_spare_servers     = $drupal_sandbox::params::fpm_min_spare_servers,
    $fpm_max_spare_servers     = $drupal_sandbox::params::fpm_max_spare_servers,
    $innodb_buffer_pool_size   = $drupal_sandbox::params::innodb_buffer_pool_size,
    $innodb_log_file_size      = $drupal_sandbox::params::innodb_log_file_size
) inherits drupal_sandbox::params {

  if ! ($use_varnish == false or $use_varnish == true) {
    fail('use_varnish must be true of false (without quotes)')
  }

  Exec { path => '/usr/bin:/bin:/usr/sbin:/sbin' }

  # Ensure apt sources are setup before installing any packages
  Apt::Source <| |> -> Package <| |>

  # Set up all apt sources:
  include drupal_sandbox::apt_src


  $mysqlpass                 = random_password(24)

  class { 'perconadb':
    password                => $mysqlpass,
    innodb_buffer_pool_size => $innodb_buffer_pool_size,
    innodb_log_file_size    => $innodb_log_file_size
  }


  # Make sure we have PHP installed before drush
  Class['Php'] -> Class['Drush']

  class { 'drush': version => '6.7.0' }

  # Force apt-get upadate to happen before we start installing php packages
  Class['Apt::Update'] ~> Class['Php']

  class {'php':
    memory_limit          => $php_memory_limit,
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

  # If we don't use varnish and apache_port was not explicitly defined,
  # use port 80 (where varnish would normally listen).
  if ! $use_varnish and ($apache_port == $drupal_sandbox::params::apache_port) {
    $this_apache_port = 80
  } else {
    $this_apache_port = $apache_port
  }
  class { 'apache2':
    addr               => $apache_addr,
    port               => $this_apache_port,
    mpm_wk_max_clients => $apache_mpm_wk_max_clients,
  }
  class { 'apache2::vhost_alias':
    addr                  => $apache_addr,
    port                  => $this_apache_port,
    virtual_document_root => $virtual_document_root
  }

  if $use_varnish {
    include varnish
  }



  # install postfix, set local email delivery to one central account:
  class { 'drupal_sandbox::postfix_catchall':
    catchall_user => 'localmail',
    manage_user   => true,
  }


}

