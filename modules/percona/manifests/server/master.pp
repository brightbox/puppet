# Replication master configuration
class percona::server::master($repl_password = "") {
    mysql_user { "repl@%":
      password_hash => mysql_password($repl_password),
    }
    mysql_grant { "repl@%":
      privileges => repl_slave_priv,
      require => Mysql_user["repl@%"],
    }
}
