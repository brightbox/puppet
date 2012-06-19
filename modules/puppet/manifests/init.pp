# Ubuntu specific
class puppet::client($enable = true, $puppet_server = "") {

	package { "puppet":
		ensure => installed
  }

  service { "puppet":
    ensure => $enable,
    enable => $enable,
    hasstatus => true,
		hasrestart => true,
    require => Package["puppet"]
  }

  file { "/etc/puppet/puppet.conf":
    ensure => file,
    content => template("puppet/client-puppet.conf.erb"),
    require => Package["puppet"],
    notify => Service["puppet"]
  }

  file { "/etc/default/puppet":
    ensure => file,
    content => "START=yes",
    require => Package["puppet"],
    before => Service["puppet"]
  }
  
}
