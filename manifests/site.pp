node default {
  class { "basic_server":
  }

  package { "haproxy":
    ensure => installed
  }

}
