node "puppet-rspec.nrpe.server" {
  include "brightbox::base"
  nagios::nrpe::config { "check_uptime":
    content => "check_uptime_command"
  }
  nagios::nrpe::command{ "check_randomness":
    command => "check_randomness_command"
  }
  class { "nagios::nsca":
    server => true
  }
}

node "puppet-rspec.custom.nrpe.server" {
  class { "brightbox::base": nrpe_load_warning => 50 }
}
