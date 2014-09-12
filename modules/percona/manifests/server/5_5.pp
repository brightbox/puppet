# Version specific classes to install the correct packages and
# perform any version specific configuration
class percona::server::5_5 {
  include "percona::server::auth_socket"
  package { "mysql-client":
    name => "percona-server-client-5.5",
    ensure => installed,
    require => File["/etc/mysql/conf.d/base.cnf"],
  }
  package { "mysql-server":
    name => "percona-server-server-5.5",
    ensure => installed,
    require => File["/etc/mysql/conf.d/base.cnf"],
  }
}
