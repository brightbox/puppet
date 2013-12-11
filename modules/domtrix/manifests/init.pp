class domtrix (
  $mquser = hiera('domtrix::mquser'),
  $mqpassword = hiera('domtrix::mqpassword'),
  $mqhosts = hiera('domtrix::mqhosts'),
  $queue = hiera('domtrix::queue'),
  $ftplogin = hiera('domtrix::ftplogin', undef),
  $ftppassword = hiera('domtrix::ftppassword', undef)
)
{
  
  package { "domtrix-lb":
    ensure => installed
  }

  file { "domtrix-config":
    path => '/etc/domtrix/config.yml',
    content => template("domtrix/config.erb"),
    require => Package[domtrix-lb]
  }

  exec { "domtrix-service-conf":
    creates => "/etc/init/${queue}.conf",
    command => "/usr/sbin/dom-service-create ${domtrixtype} ${queue}",
  }

  service { "domtrix-service":
    subscribe => File[domtrix-config],
    require => Exec[domtrix-service-conf],
    name => $queue,
    ensure => running,
    enable => true
  }
  
}
