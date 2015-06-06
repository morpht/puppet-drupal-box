class drupal_sandbox::params {

  # Apache address to listen on
  $apache_addr = '*'
  # Apache port to listen on
  $apache_port = 8080 # we have varnish in front of it at port 80

  $php_memory_limit = '96M'

  # Assign memcache memory based on total memory: rather than matching m1.medium, m1.large
  # and m1.xlarge, we are testing for >14GB, >7GB and >3GB:
  $mem_in_gb = memorysizeraw() / 1024 / 1024 / 1024

  if      $mem_in_gb > 14 { $memcache_mem   = 512
                            $apc_mem        = '256M'

                            $apache_mpm_wk_max_clients = 125
                            $fpm_max_children      = 56
                            $fpm_start_servers     = 20
                            $fpm_min_spare_servers = 8
                            $fpm_max_spare_servers = 20

                            $innodb_buffer_pool_size = '10G'
                            $innodb_log_file_size    = '512M'

  } elsif $mem_in_gb >  7 { $memcache_mem   = 385
                            $apc_mem        = '256M'

                            $apache_mpm_wk_max_clients = 75
                            $fpm_max_children      = 28
                            $fpm_start_servers     = 10
                            $fpm_min_spare_servers = 4
                            $fpm_max_spare_servers = 15

                            $innodb_buffer_pool_size = '5G'
                            $innodb_log_file_size    = '256M'

  } elsif $mem_in_gb >  3 { $memcache_mem   = 256
                            $apc_mem        = '128M'

                            $apache_mpm_wk_max_clients = 50
                            $fpm_max_children      = 12
                            $fpm_start_servers     = 5
                            $fpm_min_spare_servers = 3
                            $fpm_max_spare_servers = 11

                            $innodb_buffer_pool_size = '1536M'
                            $innodb_log_file_size    = '128M'

  } else                  { $memcache_mem   = 64
                            $apc_mem        = '64M'

                            $apache_mpm_wk_max_clients = 50
                            $fpm_max_children      = 4
                            $fpm_start_servers     = 2
                            $fpm_min_spare_servers = 1
                            $fpm_max_spare_servers = 3

                            $innodb_buffer_pool_size = '128M'
                            $innodb_log_file_size    = '64M'
  }

}

