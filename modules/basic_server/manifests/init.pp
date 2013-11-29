class basic_server {
  
  class { "apt":
    refreshonly => false,
    autoupgrade => true
  }

  class { "apt::unattended_upgrades":
  }

  class { "ssh_activate":
  }

  swap::file { "swap":
    name => '/swapfile'
  }

  package { "language-pack-en":
    ensure => installed
  }

  package { "whoopsie":
    ensure => purged
  }

}
