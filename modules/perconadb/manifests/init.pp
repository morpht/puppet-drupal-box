# == Class: perconadb
#
# This class installs perconadb.
# For Debian based systems only.
#
# === Details:
#
# Root password will be stored in /etc/mysql/root-passwd
# for other scripts to use.
#
# === Parameters
#
#  Document parameters here.
#
# [*password*]
#  The mysql root password. If not passed, a random one will be generated.
#
# [*innodb_buffer_pool_size*]
#  http://dev.mysql.com/doc/refman/5.5/en/innodb-parameters.html#sysvar_innodb_buffer_pool_size
# 
# [*innodb_log_file_size*]
#  http://dev.mysql.com/doc/refman/5.5/en/innodb-parameters.html#sysvar_innodb_log_file_size
#  It cannot be changed after the mysql server has been installed (requires
#  a special procedure).
#
# === Examples
#
# class { 'perconadb':  password => 'rootpass'  }
# include perconadb
#
# === Authors
#
# Marji Cermak <marji@morpht.com>
#
#
class perconadb(
  $password                = undef,
  $innodb_buffer_pool_size = '128M',
  $innodb_log_file_size    = '64M'
) {

  package { 'percona-server-common-5.5': 
    ensure => installed,
    before => File['/etc/mysql/my.cnf'],
  }

  package { [ 'percona-server-server-5.5', 'percona-server-client-5.5' ]:
    ensure  => present,
    require => File['/etc/mysql/my.cnf'],
  }

  # we want to install my.cnf BEFORE the server package gets installed (and started)
  # to avoid trouble with http://dba.stackexchange.com/questions/1261/how-to-safely-change-mysql-innodb-variable-innodb-log-file-size/
  file { '/etc/mysql/my.cnf':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('perconadb/my.cnf.erb'),
  }

  service { 'mysql':
    enable    => true,
    ensure    => running,
    subscribe => File['/etc/mysql/my.cnf'],
  }

  $pass = $password ? {
    undef   => random_password(24),
    default => $password,
  }

  # create a password file from the random pass.
  # but only if the file doesn't exist yet - therefore, we use the random pass only once.
  exec {'create-root-passwd-file':
    command => "/bin/echo $pass > /etc/mysql/root-passwd",
    require => Package['percona-server-server-5.5'],
    unless  => 'test -f /etc/mysql/root-passwd',
  }
  # fix the password file properties
  file {'/etc/mysql/root-passwd':
    ensure  => present,
    mode    => '0400',
    owner   => 'root',
    group   => 'root',
    require => Exec['create-root-passwd-file'],
  }

  exec { 'Set MySQL server root password':
    subscribe   => Package[ [ 'percona-server-server-5.5', 'percona-server-client-5.5'] ],
    refreshonly => true,
    unless      => "mysqladmin -uroot -p`/bin/cat /etc/mysql/root-passwd` status",
    path        => '/bin:/usr/bin',
    command     => "mysqladmin -uroot password `/bin/cat /etc/mysql/root-passwd`",
    logoutput   => 'true',
    require     => Exec['create-root-passwd-file'],
  }



#  # Equivalent to /usr/bin/mysql_secure_installation without providing or setting a password
#  exec { 'mysql_secure_installation':
#    command => '/usr/bin/mysql -uroot -e "DELETE FROM mysql.user WHERE User=\'\'; DELETE FROM mysql.user WHERE User=\'root\' AND Host NOT IN (\'localhost\', \'127.0.0.1\', \'::1\'); DROP DATABASE IF EXISTS test; FLUSH PRIVILEGES;" mysql',
#    require => Service['mysqld'],
#  }

}
