node default {
  class { "apt":
    refreshonly => false,
    autoupgrade => true
  }

  class { "apt_cacher_ng":
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
