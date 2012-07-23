# rsyslog recipe. John Leach <john@brightbox.co.uk>
#
# Only supports Ubuntu.
#
# Set remote_servers to an array of servers to send messages to (via
# tcp). Can optionally include port separated with a colon.
#
# Set per_host_logs to true to write logs to /var/log/by-host
# according the the IP and hostname the message came in from (only
# useful with tcp or udp enabled!)
#
# e.g: class { rsyslog:
#        remote_servers => ["10.0.0.1", "10.0.0.2:2514"]
#      }
#
class rsyslog($remote_servers = false, $per_host_logs = false) {

	package { "rsyslog":
    ensure => installed,
  }

  service { "rsyslog":
    ensure => running,
    hasstatus => true,
    require => Package["rsyslog"]
  }

  if $per_host_logs {
    file { "/etc/rsyslog.d/per_host_logs.conf":
      ensure => file,
      content => "# Managed by puppet\n\$template FileNamePerHost,\"/var/log/by-host/%hostname%-%fromhost-ip%.log\"\n*.* -?FileNamePerHost;RSYSLOG_SyslogProtocol23Format",
      notify => Service["rsyslog"],
      require => [Package["rsyslog"], File["/var/log/by-host"]]
    }
    file { "/var/log/by-host":
      ensure => directory,
      owner => syslog,
      group => syslog
    }
    # Fixes a bug in rsyslog in Ubuntu where it creates files but
    # refuses to write to them.
    file { "/etc/rsyslog.d/fix_filegroup.conf":
      ensure => file,
      content => "# Managed by puppet\n\$FileGroup syslog\n",
      notify => Service["rsyslog"],
      require => Package["rsyslog"]
    }

    file { "/etc/logrotate.d/rsyslog-by-host":
      ensure => file,
      content => template("rsyslog/logrotate-rsyslog-by-host.erb")
    }
  } else {
    file { "/etc/rsyslog.d/per_host_logs.conf":
      ensure => absent,
      notify => Service["rsyslog"],
      require => Package["rsyslog"]
    }
  }

  if $remote_servers {
    file { "/etc/rsyslog.d/send-remote.conf":
      ensure => file,
      content => template("rsyslog/send-remote.conf.erb"),
      require => [Package["rsyslog"], File["/var/spool/rsyslog"]],
      notify => Service["rsyslog"]
    }
    # NOTE: Ubuntu specific. There is no syslog user in Centos
    file { "/var/spool/rsyslog":
      ensure => directory,
      owner => syslog,
      group => syslog,
      require => Package["rsyslog"]
    }
  } else {
    file { "/etc/rsyslog.d/send-remote.conf":
      ensure => absent,
      notify => Service["rsyslog"]
    }
  }
}

# Enable or disable the rsyslog tcp server
class rsyslog::tcp($enable = true, $tcp_max = 200) {
  file { "/etc/rsyslog.d/tcp.conf":
    ensure => $enable ? {
      true => file,
      false => absent
    },
    content => "# Managed by puppet\n\$ModLoad imtcp\n\$InputTCPServerRun 514\n\$InputTCPMaxSessions $tcp_max\n",
    notify => Service["rsyslog"],
    require => Package["rsyslog"]
  }
}

# Enable or disable the rsyslog udp server
class rsyslog::udp($enable = true) {
  # NOTE: Ubuntu specific. Centos does not have the rsyslog.d dir by
  # default
  file { "/etc/rsyslog.d/udp.conf":
    ensure => $enable ? {
      true => file,
      false => absent
    },
    content => "# Managed by puppet\n\$ModLoad imudp\n\$UDPServerRun 514",
    notify => Service["rsyslog"],
    require => Package["rsyslog"]
  }
}
