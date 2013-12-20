class mys_service (
  $admin_password = hiera("mys_service::admin_password", ''),
  $admin_username = hiera("mys_service::admin_username", 'admin'),
  $mysql_data_dir = hiera("mys_service::mysql_data_dir", '/var/lib/mysql'),
)
{

  Class['basic_server'] -> Class['mys_service']

  package { 'mylvmbackup':
    ensure => installed
  }

  class { "mys_service::data_dir":
    mysql_data_dir => $mysql_data_dir,
    before => [
      Class['percona::server::5_5'],
      Class['percona::server::base']
    ]
  }

  ssl::cert::selfsigned { "mysql":
    state => "West Yorkshire",
    country => "GB",
    organisation => "Brightbox Cloud",
    days => 3650,
    before => Class['percona::server::base']
  }

  class { "percona::server::5_5": }

  class { "percona::server::base":
    ssl => true,
    ssl_key => "/etc/ssl/private/mysql.key",
    ssl_cert => "/etc/ssl/certs/mysql.crt",
    data_dir => $mysql_data_dir,
  }

  if $admin_password != '' {

    mysql_user { "${admin_username}@%":
      password_hash => mysql_password(hiera("admin_password")),
    }

    mysql_grant { "${admin_username}@%":
      # FIXME: event_priv, trigger
      privileges => [grant_priv, create_priv, drop_priv, references_priv,
	alter_priv, delete_priv, index_priv, insert_priv, select_priv,
	update_priv, create_tmp_table_priv, lock_tables_priv,
	create_view_priv, show_view_priv, create_routine_priv,
	alter_routine_priv, execute_priv, create_user_priv, process_priv,
	show_db_priv
      ],
      require => Mysql_user["${admin_username}@%"],
    }
    
  }

}
