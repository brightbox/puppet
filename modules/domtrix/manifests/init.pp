class domtrix (
  $mquser = hiera('domtrix::mquser'),
  $mqpassword = hiera('domtrix::mqpassword'),
  $mqhosts = hiera('domtrix::mqhosts'),
  $queue = hiera('domtrix::queue'),
  $domtrixtype = hiera('domtrix::service'),
  $ftplogin = hiera('domtrix::ftplogin', undef),
  $ftppassword = hiera('domtrix::ftppassword', undef),
  $notify_service = hiera('domtrix::notify_service', 'yes'),
  $cache_dir = hiera('domtrix::cache_dir', '/tmp'),
  $snapshot_cache_dir = hiera('domtrix::snapshot_cache_dir', '/tmp'),
  $cache_max_blocks = hiera('domtrix::cache_max_blocks', 4096),
  $upload_segment_size = hiera('domtrix::upload_segment_size', 1073741824)
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
