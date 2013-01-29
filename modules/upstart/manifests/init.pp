# Initial upstart class, currently only used to turn on user jobs in Ubuntu
class upstart($user_jobs = true) {

	package { "upstart":
		ensure => installed
  }

  if $user_jobs {
    $source = "puppet:///modules/upstart/Upstart.conf.user-jobs"
    file { "/etc/init/load-user-jobs.conf":
      source => "puppet:///modules/upstart/load-user-jobs.conf"
    }
  }
  else {
    $source = "puppet:///modules/upstart/Upstart.conf.standard"
    file { "/etc/init/load-user-jobs.conf":
      ensure => absent
    }
  }

  file { "/etc/dbus-1/system.d/Upstart.conf":
    source => $source,
    require => Package[upstart],
    owner => root, group => root
  }
}
