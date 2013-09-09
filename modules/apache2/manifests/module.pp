define apache2::module ( $ensure = 'present', $require_package = 'apache2' ) { 
    case $ensure {
        'present' : { 
            exec { "/usr/sbin/a2enmod $name":
                unless  => "[ -L /etc/apache2/mods-enabled/${name}.load ]",
               	notify  => Service["apache2"],
                require => Package[$require_package],
            }
        }
        'absent': {
            exec { "/usr/sbin/a2dismod $name":
                onlyif  => "[ -L /etc/apache2/mods-enabled/${name}.load ]",
                notify  => Service["apache2"],
                require => Package[$require_package],
            }
        }
    }
}

