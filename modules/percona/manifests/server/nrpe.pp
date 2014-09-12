# NRPE config
#
# slave_warning is the number of seconds of replication delay to
# trigger a nagios warning.
#
# slave_critical is the number of seconds of replication delay to
# trigger a nagios critical alert.
#
# The nrpe config is only written if the node is tagged "nrpe"
#
class percona::server::nrpe($slave_warning = 60, $slave_critical = 300) {

    nagios::nrpe_config { "mysql_server":
      content => template("percona/nrpe_mysql.cfg.erb")
    }

    mysql_user { "status@localhost": }
    mysql_grant { "status@localhost":
      privileges => [repl_client_priv, process_priv],
      require => Mysql_user["status@localhost"]
    }
}
