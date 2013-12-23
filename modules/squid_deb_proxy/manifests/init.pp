#Setup squid-deb-proxy package and set the service running

class squid_deb_proxy
{
  package { "squid-deb-proxy": 
    ensure => installed
  }

  service { "squid-deb-proxy": 
    require => Package["squid-deb-proxy"],
    ensure => running,
    enable => true
  }

  file { "allowed-domains":
    require => Package["squid-deb-proxy"],
    notify => Service['squid-deb-proxy'],
    name => '/etc/squid-deb-proxy/mirror-dstdomain.acl.d/20-puppet',
    content => template('squid_deb_proxy/allowed-domains')
  }

}
