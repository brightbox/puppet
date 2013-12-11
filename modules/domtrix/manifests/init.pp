class domtrix (
  $mquser = hiera('domtrix::mquser'),
  $mqpassword = hiera('domtrix::mqpassword'),
  $mqhosts = hiera('domtrix::mqhosts'),
  $queue = hiera('domtrix::queue'),
  $domtrixtype = hiera('domtrix::service'),
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

  file { "domtrix-service-conf":
    path => "/etc/init/${queue}.conf",
    content => template("domtrix/service-init.erb")
  }

  service { "domtrix-service":
    subscribe => File[domtrix-config],
    require => Exec[domtrix-service-conf],
    name => $queue,
    ensure => running,
    enable => true
  }
  
}
