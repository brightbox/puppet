class mys_service::data_dir(
  $mysql_data_dir,
  $mysql_tmp_dir
) {

  $data_device='/dev/mysql/data'

  package { "lvm2":
    ensure => installed
  }

  package { "thin-provisioning-tools":
    ensure => installed
  }

  package { "xfsprogs":
    ensure => installed
  }

  file { "create-mysql-partition-script":
    name => '/var/lib/cloud/scripts/per-once/50_create_thin_data.sh',
    content => template('mys_service/50_create_thin_data.sh'),
    mode => 0755,
    owner => root,
    group => root
  }

  file { "extend-mysql-partition-script":
    name => '/var/lib/cloud/scripts/per-boot/50_extend_thin_data.sh',
    content => template('mys_service/50_extend_thin_data.sh'),
    mode => 0755,
    owner => root,
    group => root
  }

  file { "data_dir_mount_point":
    name => $mysql_data_dir,
    ensure => directory,
  }

  file { "mysql_tmp_dir":
    name => $mysql_tmp_dir,
    ensure => directory,
  }

  exec { "create-mysql-partition":
    require => [
      Package['lvm2'],
      Package['xfsprogs'],
      Package['thin-provisioning-tools'],
      File['create-mysql-partition-script']
    ],
    creates => $data_device,
    command => '/var/lib/cloud/scripts/per-once/50_create_thin_data.sh',
  }

  mount { "mount-data-partition":
    require => [
      Exec['create-mysql-partition'],
      File['data_dir_mount_point']
    ],
    before => [
      File['mysql_tmp_dir']
    ],
    name => $mysql_data_dir,
    atboot => true,
    device => $data_device,
    options => 'defaults',
    ensure => mounted,
    fstype => 'xfs'
  }

}

