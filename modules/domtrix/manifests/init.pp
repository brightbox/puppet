class domtrix (
  $mquser = hiera('domtrix::mquser'),
  $mqpassword = hiera('domtrix::mqpassword'),
  $mqhosts = hiera('domtrix::mqhosts'),
  $queue = hiera('domtrix::queue'),
  $domtrixtype = hiera('domtrix::service'),
  $ftplogin = hiera('domtrix::ftplogin', undef),
  $ftppassword = hiera('domtrix::ftppassword', undef),
  $notify_service = hiera('domtrix::notify_service', 'yes')
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

  file { "domtrix-service-init-script":
    path => "/etc/init/${queue}.conf",
    content => template("domtrix/service-init.erb")
  }

  if $notify_service == 'yes' {
    service { "domtrix-service":
      subscribe => File[domtrix-config],
      require => File[domtrix-service-init-script],
      name => $queue,
      ensure => running,
      enable => true
    }
  }
  
}
