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
  $tmp_dir = "${percona::params::data_dir}/.#tmp",
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
