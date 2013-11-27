node default {
  include apt
  include apt_cacher_ng

  package { "language-pack-en":
    ensure => installed
  }

}
