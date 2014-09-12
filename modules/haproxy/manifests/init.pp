class haproxy (
  $active = hiera('haproxy::active', false),
  $config = hiera('haproxy::config', ''),
  $cert = hiera('haproxy::cert', '')
)
{
  Class['basic_server'] -> Class['haproxy'] -> Class['domtrix']

  $default_enabled = $active ? {
    true => 1,
    false => 0
  }

  package { "haproxy":
    ensure => installed
  }

  file { "haproxy-config":
    path => "/etc/haproxy/haproxy.cfg",
    content => $config,
    require => Package[haproxy]
  }

  augeas { "haproxy-default":
    incl => '/etc/default/haproxy',
    require => Package[haproxy],
    lens => 'Shellvars.lns',
    changes => [
      "set ENABLED $default_enabled"
    ]
  }

  file { "haproxy-cert":
    path => "/etc/haproxy/ssl_cert.pem",
    content => $cert,
    require => Package[haproxy]
  }

  service { "haproxy-service":
    name => 'haproxy',
    subscribe => [
      File['haproxy-cert'],
      File['haproxy-config'],
      Augeas['haproxy-default']
    ],
    enable => $active,
    ensure => $active
  }

}
