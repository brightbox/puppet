class basic_server::minimal (
  $upgrade_minute = hiera("basic_server::minimal::upgrade_minute", fqdn_rand(30)),
  $upgrade_hour = hiera("basic_server::minimal::upgrade_hour", 6),
  $upgrade_weekday = hiera("basic_server::minimal::upgrade_weekday", 'Sunday'),
) {
  
  class { "apt":
    refreshonly => false,
    autoupgrade => false,
  }

  class { "apt::unattended_upgrades":
    origins => ['origin=${distro_id},suite=${distro_codename}-security',
      'label=percona,component=main'],
    minimal_steps => true,
    max_size => 512,
    upgrade => 0,
  }

  file {
    '/etc/apt/apt.conf.d/10retainconfigs':
      content => template('basic_server/10retainconfigs');
  }

  cron { "unattended_upgrade":
    command => "/usr/bin/unattended-upgrade",
    ensure => present,
    hour => $upgrade_hour,
    minute => $upgrade_minute,
    weekday => $upgrade_weekday,
    user => 'root',
    environment => 'PATH=/usr/sbin:/usr/bin:/sbin:/bin',
    require => Class["apt::unattended_upgrades"],
  }

  package { "language-pack-en":
    ensure => installed
  }

  package { ["update-notifier-common", "whoopsie", "mlocate", "man-db", "apt-xapian-index"]:
    ensure => purged,
    require => File["/var/lib/man-db/auto-update"]
  }

  file { "/var/lib/man-db/auto-update":
    ensure => absent
  }

  service { "puppet":
    ensure => stopped,
    enable => false
  }

}
