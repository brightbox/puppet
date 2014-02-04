class basic_server {
  
  class { "apt":
    refreshonly => false,
    autoupgrade => true
  }

  class { "apt::unattended_upgrades":
    origins => ['origin=${distro_id},suite=${distro_codename}-security',
      'label=percona,codename=${distro_codename}'],
    minimal_steps => true,
    max_size => 512,
  }

  class { "ssh_activate":
  }

  swap::file { "swap":
    name => '/.swapfile',
    size => 512
  }

  package { "language-pack-en":
    ensure => installed
  }

  package { "whoopsie":
    ensure => purged
  }

  service { "puppet":
    ensure => stopped,
    enable => false
  }

}
