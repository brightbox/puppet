class mys_service::data_dir(
  $mysql_data_dir
) {

  $data_device='/dev/mysql/data'

  package { "data_dir_progs":
    name => [ 'lvm2', 'thin-provisioning-tools', 'xfsprogs' ],
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

  exec { "create-mysql-partition":
    require => [
      Package['data_dir_progs'],
      File['create-mysql-partition-script']
    ],
    creates => $data_device,
    command => '/var/lib/cloud/scripts/per-once/50_create_thin_data.sh',
  }

  mount { "mount-data-partition":
    require => Exec['create-mysql-partition'],
    name => $mysql_data_dir,
    atboot => true,
    device => $data_device,
    ensure => mounted,
    fstype => 'xfs'
  }

}

