#Setup squid-proxy-deb package and set the service running

class squid_proxy_deb
{
  package { "squid-proxy-deb": 
    ensure => installed
  }

  service { "squid-proxy-deb": 
    require => Package["squid-proxy-deb"],
    ensure => running,
    enable => true
  }

  file { "allowed-domains":
    require => Package["squid-proxy-deb"],
    notify => Service['squid-proxy-deb'],
    name => '/etc/squid-deb-proxy/mirror-dstdomain.acl.d/20-puppet-conf'
    content => template('squid_proxy_deb/allowed-domains')
  }

}
