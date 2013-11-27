#Setup apt-cacher-ng package and set the service running

class apt_cacher_ng 
{
  package { "apt-cacher-ng": 
    ensure => installed
  }

  service { "apt-cacher-ng": 
    require => Package["apt-cacher-ng"]
  }

}
