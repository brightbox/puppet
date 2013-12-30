class git-daemon {

  $base_path='/var/lib'
  $git_daemon_directory="${base_path}/git"

  package { "git-daemon":
    name => "git-daemon-sysvinit",
    ensure => installed
  }

  service { "git-daemon":
    name => "git-daemon",
    subscribe => Augeas["git-daemon-default"], File["git-dir"]
    ensure => running,
    enable => true
  }

  augeas { "git-daemon-default":
    incl => '/etc/default/git-daemon',
    require => Package["git-daemon"],
    lens => 'Shellvars.lns',
    changes => [
      "set GIT_DAEMON_ENABLE true",
      "set GIT_DAEMON_OPTIONS --export-all",
      "set GIT_DAEMON_BASE_PATH ${base_path}",
      "set GIT_DAEMON_DIRECTORRY ${git_daemon_directory}"
    ]
  }

  file { "git-dir":
    path => $git_daemon_directory,
    ensure => directory,
    group => sudo,
    owner => root,
    mode => '2775'
  }

}
