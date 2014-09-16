class basic_server (
  $upgrade_minute = hiera("basic_server::upgrade_minute", fqdn_rand(30)),
  $upgrade_hour = hiera("basic_server::upgrade_hour", 6),
  $upgrade_weekday = hiera("basic_server::upgrade_weekday", 'Sunday'),
) {
 
  class { "basic_server::minimal":
    upgrade_minute => $upgrade_minute,
    upgrade_hour => $upgrade_hour,
    upgrade_weekday => $upgrade_weekday,
  }

  class { "ssh_activate":
  }

  swap::file { "swap":
    name => '/.swapfile',
    size => 512
  }

}
