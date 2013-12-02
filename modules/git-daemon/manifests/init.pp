class git-daemon {

  package { "git-daemon":
    name => "git-daemon-sysvinit",
    ensure => installed
  }

  service { "git-daemon":
    name => "git-daemon",
    require => Package["git-daemon"],
    subscribe => Augeas["git-daemon-default"],
    ensure => running,
    enable => true
  }

  augeas { "git-daemon-default":
    incl => '/etc/default/git-daemon',
    require => Package["git-daemon"],
    lens => 'Shellvars.lns',
    changes => [
      "set GIT_DAEMON_ENABLE true",
      "set GIT_DAEMON_OPTIONS --export-all"
    ]
  }

}
