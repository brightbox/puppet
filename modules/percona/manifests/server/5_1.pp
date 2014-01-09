class percona::server::5_1 {
  package { "mysql-client":
    name => "percona-server-client-5.1",
    ensure => installed,
    require => File["/etc/mysql/conf.d/base.cnf"],
  }
  package { "mysql-server":
    name => "percona-server-server-5.1",
    ensure => installed,
    require => File["/etc/mysql/conf.d/base.cnf"],
  }
}
