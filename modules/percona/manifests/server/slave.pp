# Replication slave configuration
#
# master_host is the hostname or IP of the master
#
# slave_skip_errors should be either false, or a string such as
# "1062,1100". Only needed for very specific use cases.
#
class percona::server::slave($master_host = "", $repl_password = "", $slave_skip_errors = false) {
  file { "/etc/mysql/conf.d/slave.cnf":
    content => template("percona/slave.cnf.erb"),
    require => File["/etc/mysql/conf.d"]
  }
}
