node default {
  class { "basic_server":
  }

  package { "haproxy":
    ensure => installed
  }

  package { "domtrix-lb":
    ensure => installed
  }

}
