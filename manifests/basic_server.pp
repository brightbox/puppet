class basic_server {
  
  class { "apt":
    refreshonly => false,
    autoupgrade => true
  }

  class { "apt::unattended_upgrades":
  }

  package { "language-pack-en":
    ensure => installed
  }

  package { "whoopsie":
    ensure => purged
  }

}
