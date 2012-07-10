class nagios {
}

define nagios::nrpe_config($content = "") {
  if tagged("nrpe") {
    file { "/etc/nagios/nrpe.d/$name":
      content => "$content\n",
      notify => Exec["nrpe-config"],
      require => Package["nagios-nrpe-server"]
    }
  }
}

# Installs and configures a basic nagios nrpe server
class nagios::nrpe($allowed_hosts = []) {
  tag("nrpe")
  package { ["nagios-nrpe-server", "nagios-plugins", "nagios-plugins-basic", "nagios-plugins-extra", "nagios-plugins-standard"]:
    ensure => latest
  }
  exec { "nrpe-config":
    command => "/bin/cat /etc/nagios/nrpe.d/* > /etc/nagios/nrpe_puppet.cfg",
    notify => Service["nagios-nrpe-server"],
    require => Package["nagios-nrpe-server"],
    refreshonly => true
  }
  file { "/etc/nagios/nrpe.cfg":
    content => template("nagios/nrpe.cfg.erb"),
    require => Package["nagios-nrpe-server"],
    notify => Service["nagios-nrpe-server"],
    mode => 640,
    owner => root,
    group => nagios
  }
  service { "nagios-nrpe-server":
    ensure => true,
    enable => true,
    hasrestart => false,
    pattern => "nrpe",
    require => [Package["nagios-nrpe-server"], File["/etc/nagios/nrpe.cfg"]]
  }
}

# include some useful common checks like load, diskspace, and various networkchecks
# www.l.google.com usually has a ttl of 300 seconds, so handy for a recursive dns health check
#
class nagios::nrpe::commonchecks($outgoing_smtp_host = "smtp.google.com", $recursive_dns_host = "www.l.google.com", $outgoing_http_host = "www.google.co.uk", $load_warning = 15, $load_critical = 60) {
  nagios::nrpe_config { "commonchecks":
    content => template("nagios/nrpe-common.erb")
  }
}
