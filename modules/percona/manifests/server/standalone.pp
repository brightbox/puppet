# One class that provides everything required for a mysql server in
# a replicated cluster with monitoring.
class percona::server::standalone($version = "5.1", $server_id = undef, $max_servers = 2, $innodb_buffer_pool_size = 1024, $root_password = "", $repl_password = "", $master_host = "", $slave_skip_errors = false, $slave_warning = 60, $slave_critical = 300) {
  package { "maatkit":
    ensure => installed
  }
  class { "percona::server::base":
    server_id => $server_id,
    max_servers => $max_servers,
    innodb_buffer_pool_size => $innodb_buffer_pool_size,
    root_password => $root_password,
  }
  case $version {
    "5.5": { include percona::server::5_5 } 
    "5.0": { include percona::server::5_0  } 
    default:  { include percona::server::5_1 } 
  }
  class { "percona::server::master":
    repl_password => $repl_password
  }
  class { "percona::server::slave":
    master_host => $master_host,
    repl_password => $repl_password,
    slave_skip_errors => $slave_skip_errors
  }
  class { "percona::server::nrpe":
    slave_warning => $slave_warning,
    slave_critical => $slave_critical
  }
}
