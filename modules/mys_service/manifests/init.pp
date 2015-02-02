class mys_service (
  $admin_password = hiera("mys_service::admin_password", ''),
  $admin_username = hiera("mys_service::admin_username", 'admin'),
  $mysql_data_dir = hiera("mys_service::mysql_data_dir", '/var/lib/mysql'),
  $mysql_tmp_dir = hiera("mys_service::mysql_tmp_dir", ".#tmp"),
  $mysql_version = hiera("mys_service::version", '5.5')
)
{

  $mysql_package_version = $mysql_version ? {
    '5.6'	=> '5_6',
    default	=> '5_5',
  }

  $full_mysql_tmp_dir = "${mysql_data_dir}/${mysql_tmp_dir}"

  package { 'mylvmbackup':
    ensure => installed,
    before => Class['domtrix']
  }

  package { 'uricp':
    ensure => installed,
    provider => 'gem',
    before => Class['domtrix']
  }

  package { ['ruby-dev', 'make']:
    ensure => installed,
    before => Package['uricp']
  }

  package { 'liblz4-tool':
    ensure => installed,
    before => Class['domtrix']
  }

  file { 'mylvmbackup_config':
    require => Package['mylvmbackup'],
    name => '/etc/mylvmbackup.conf',
    mode => 0600,
    owner => root,
    group => root,
    content => template('mys_service/mylvmbackup.conf'),
  }
  
  service { 'mysql':
    ensure => running,
    enable => true,
    require => [
      Class ["percona::server::${mysql_package_version}"]
    ],
    before => [
      Class['domtrix']
    ]
  }

  Service['mysql'] -> Mysql_user <| |>

  class { "mys_service::data_dir":
    mysql_data_dir => $mysql_data_dir,
    mysql_tmp_dir => $full_mysql_tmp_dir,
    before => [
      Class["percona::server::${mysql_package_version}"],
    ]
  }

  ssl::cert::selfsigned { "mysql":
    state => "West Yorkshire",
    country => "GB",
    organisation => "Brightbox Cloud",
    days => 3650,
  }

  class { "percona::server::${mysql_package_version}": }

  class { "percona::server::base":
    ssl => true,
    ssl_key => "/etc/ssl/private/mysql.key",
    ssl_cert => "/etc/ssl/certs/mysql.crt",
    data_dir => $mysql_data_dir,
    tmp_dir => $full_mysql_tmp_dir,
    before => Class['domtrix']
  }

  if $admin_password != '' {

    mysql_user { "${admin_username}@%":
      password_hash => mysql_password($admin_password),
      require => Service['mysql']
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
