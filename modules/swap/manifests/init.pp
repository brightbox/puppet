# name is path to the swap file
# size is in megabytes
define swap::file($size = 1024) {

  exec { "create-swap-for-$name":
    creates => $name,
    path => "/bin",
    command => "dd if=/dev/zero of=${name} bs=1M count=${size}",
    notify => Exec["mkswap-for-$name"]
  }

  exec { "mkswap-for-$name":
    refreshonly => true,
    path => "/sbin",
    command => "mkswap ${name}",
    notify => Exec["swapon-for-$name"]
  }

  exec { "swapon-for-$name":
    refreshonly => true,
    path => "/sbin",
    command => "swapon ${name}"
  }

  mount { $name:
    device => "$name",
    fstype => swap,
    ensure => defined,
    atboot => true,
    options => defaults,
    require => Exec["mkswap-for-$name"]
  }

  augeas { "sysctl-for-$name":
    context => "/files/etc/sysctl.conf",
    changes => [
      "set vm.swappiness = 10",
    ],
    notify => Exec["sysctl-reload-for-$name"]
  }

  exec { "sysctl-reload-for-$name":
    path        => ['/sbin'],
    command     => 'sysctl -p /etc/sysctl.conf',
    refreshonly => true,
    subscribe   => File['/etc/sysctl.conf']
  }

}
