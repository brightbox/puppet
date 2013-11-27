node default {
  apt {refreshonly => false}
  include apt_cacher_ng

  package { "language-pack-en":
    ensure => installed
  }

}
