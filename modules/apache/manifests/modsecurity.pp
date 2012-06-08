class apache::modsecurity($datadir = "/var/lib/modsecurity") {

  package { libapache-mod-security:
    ensure => installed,
    require => Package[apache2]
  }

  apache::module { 'mod-security':
    conf => false
  }

  file { $datadir:
    ensure => directory,
    owner => www-data,
    group => www-data,
    mode => 750,
    require => Package[apache2]
  }
  
  file { "/etc/apache2/conf.d/modsecurity":
    content => "SecDataDir $datadir\n",
    require => File[$datadir]
  }

}
