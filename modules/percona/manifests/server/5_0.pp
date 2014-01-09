class percona::server::5_0 {
  package { "mysql-client":
    name => "percona-sql-client-5.0",
    ensure => installed,
    require => File["/etc/mysql/conf.d/base.cnf"],
  }
  package { "mysql-server":
    name => "percona-sql-server-5.0",
    ensure => installed,
    require => File["/etc/mysql/conf.d/base.cnf"],
  }
}
