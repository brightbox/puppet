node default {
  class { "apt":
    refreshonly => false
  }
  class { "apt_cacher_ng":
  }

  package { "language-pack-en":
    ensure => installed
  }

}
