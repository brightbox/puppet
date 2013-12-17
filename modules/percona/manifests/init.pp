class percona {

}

class percona::params {
  $innodb_buffer_pool_size = ($::memorysizeinbytes / 1024 / 1024) * 0.70
  $key_buffer_size = ($::memorysizeinbytes / 1024 / 1024) * 0.05
  $data_dir = "/var/lib/mysql"
}

# Binary logging is disabled by default, but is automatically enabled
# when a server_id is set.
#
# server_id should be a uniq integer, starting at 1, no more than
# max_servers
#
# max_servers should be the number of masters in the ring (usually 2 in master <-> master)
#
# innodb_buffer_pool_size is amount of ram to use for innodb, in
# megabytes. Defaults to 70% of ram.
#
# key_buffer_size is in megabytes. Defaults to 5% of ram.
#
# ssl is enabled by default, and defaults to using the Debian snakeoil
# certs. You can define custom cert and key paths, but you need to
# have File resources defined for them elsewhere. They must exist
# before mysql will be installed.
#
class percona::server::base(
  $root_password = undef,
  $root_auth_socket = true,
  $max_servers = 2,
  $server_id = false,
  $ssl = true,
  $ssl_ca = false,
  $ssl_cert = "/etc/ssl/ssl-cert-snakeoil.pem",
  $ssl_key = "/etc/ssl/private/ssl-cert-snakeoil.key",
  $data_dir = $percona::params::data_dir,
  $innodb_buffer_pool_size = $percona::params::innodb_buffer_pool_size,
  $key_buffer_size = $percona::params::key_buffer_size
) inherits percona::params {

  apt::source { "percona":
    source => "deb http://repo.percona.com/apt $::lsbdistcodename main",
    gpg_key_id => "CD2EFD2A"
  }

  # Provide our own upstart script
  file { "/etc/init/mysql.conf":
    content => template("percona/upstart-mysql.conf.erb"),
    before => Package[mysql-server]
  }
  # Kill the package provided initscript early on
  file { "/etc/init.d/mysql":
    source => "file:///lib/init/upstart-job", # can't symlink this as a pkg post-install script seems to corrupt it
    mode => 755,
    before => Package[mysql-server],
    require => File["/etc/init/mysql.conf"]
  }
  file { "/etc/mysql":
    ensure => directory,
    mode => 755
  }
  file { "/etc/mysql/conf.d":
    ensure => directory,
    mode => 755,
    require => File["/etc/mysql"]
  }
  file { "/etc/mysql/my.cnf":
    content => "!includedir /etc/mysql/conf.d/",
    require => [File["/etc/mysql"], File["/etc/mysql/conf.d"]]
  }

  file { "/etc/mysql/conf.d/base.cnf":
    content => template("percona/base.cnf.erb"),
    require => File["/etc/mysql/conf.d"]
  }

  if $ssl {
    file { "/etc/mysql/conf.d/ssl.cnf":
      content => template("percona/ssl.cnf.erb"),
      require => [File[$ssl_cert], File[$ssl_key]]
    }
  } else {
    file { "/etc/mysql/conf.d/ssl.cnf":
      ensure => absent
    }
  }

  mysql_user { "root@$::hostname":
    ensure => absent
  }
  # Use a password to authenticate root, rather than auth_socket
  if $root_password {
    # Setup the root user first (by default, the package leaves a root account with no pw)
    mysql_user { "root@localhost":
      password_hash => mysql_password($root_password),
      require => [Package["mysql-server"], Package["mysql-client"]]
    }

    mysql_user { ["root@127.0.0.1"]:
      password_hash => mysql_password($root_password),
      require => File["/etc/my.cnf"]
    }

    # Then the config with the root password in it
    file { "/etc/my.cnf":
      mode => 600,
      content => "# Managed by puppet\n[client]\nuser = root\npassword = $root_password\n",
      require => Mysql_user["root@localhost"]
    }

    Mysql_user <| title != "root@localhost" |> <- File["/etc/my.cnf"]
  }
  else
  {
    # Use the auth_socket plugin to authenticate root, instead of a password  
    if $root_auth_socket {
      mysql_user { "root@localhost":
        identified_with => 'auth_socket',
        require => [Package["mysql-server"], Package["mysql-client"], Class[Percona::Server::Auth_socket]]
      }
      mysql_user { ["root@127.0.0.1", "root@::1"]:
        ensure => absent
      }
      Mysql_user <| title != "root@localhost" |> <- Mysql_user["root@localhost"]
    }

    mysql_user { "debian-sys-maint@localhost":
      ensure => absent
    }    
  }

  file { "/etc/mysql/debian.cnf":
    content => template("percona/debian.cnf.erb"),
    require => Mysql_user["root@localhost"]
  }

}

# Internal use only. Can only be used on server versions confirmed to
# support auth socket!
class percona::server::auth_socket {
  file { "/etc/mysql/conf.d/auth_socket.cnf":
    content => "[mysqld]\nplugin-load=auth_socket.so\n",
    require => File["/etc/mysql/my.cnf"]
  }
}

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
