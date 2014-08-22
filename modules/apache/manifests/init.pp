define apache::module($conf = true) {
  file { "/etc/apache2/mods-enabled/$name.load":
    ensure => "/etc/apache2/mods-available/$name.load",
    require => Package["apache2"],
    notify => Service["apache2"]
  }
  if $conf {
    file { "/etc/apache2/mods-enabled/$name.conf":
      ensure => "/etc/apache2/mods-available/$name.conf",
      require => [Package["apache2"], File["/etc/apache2/mods-enabled/$name.load"]],
      notify => Service["apache2"]
    }
  }    
}

define apache::site($content = undef, $source = undef) {
  file { "/etc/apache2/sites-available/$name":
    content => $content,
    source => $source,
    require => Package["apache2"],
    notify => Service["apache2"]
  }
  file { "/etc/apache2/sites-enabled/$name":
    ensure => "/etc/apache2/sites-available/$name",
    require => File["/etc/apache2/sites-available/$name"],
    notify => Service["apache2"]
  }
}


# Uses event mpm
#
# Will auto-tune thread settings using $max_clients and
# $threads_per_child. Best to leave $threads_per_child alone and just
# set $max_clients
class apache($http_ports = [80], $max_clients = 600, $threads_per_child = 50, $keepalive_timeout = 5, $keepalive = true) {
  package { "apache2":
    name => "apache2-mpm-event",
    ensure => installed
  }
  service { "apache2":
    ensure => true,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    restart => "service apache2 reload",
    require => Package["apache2"]
  }

  if $::lsbdistrelease < 14.04 {
    $apache_version = 2.2
  } else {
    $apache_version = 2.4
  }

  if $::lsbdistrelease >= 14.04 {
    # needed for ssl
    apache::module { "socache_shmcb": conf => false }

    # Make trusty act like raring/precise etc.
    file { '/etc/apache2/conf.d':
      ensure => link,
      target => '/etc/apache2/conf-enabled',
      require => Package['apache2']
    }
  }

  file { "/etc/apache2/conf.d/security":
    content => "# Managed by Puppet\nServerTokens Prod\nServerSignature Off\nTraceEnable Off\n",
    require => Package["apache2"],
    notify => Service["apache2"]
  }

  file { "/etc/apache2/ports.conf":
    content => template("apache/ports.conf.erb"),
    require => Package["apache2"],
    notify => Service["apache2"]
  }

  file { "/etc/apache2/apache2.conf":
    content => template("apache/apache.conf.erb"),
    require => Package["apache2"],
    notify => Service["apache2"]
  }

  # Create httpd.conf if it doesn't exist - simple workaround for
  # Saucy and above, whose packages don't provide it (it's included by
  # apache2.conf)
  exec { "create-httpd.conf":
    command => "/usr/bin/touch /etc/apache2/httpd.conf",
    creates => "/etc/apache2/httpd.conf",
    require => Package["apache2"]
  }

  file { "/var/log/web":
    ensure => directory
  }

  file { ["/etc/apache2/sites-enabled/000-default", "/etc/apache2/sites-enabled/default", "/etc/apache2/sites-enabled/default-ssl", "/etc/apache2/sites-enabled/000-default.conf"]:
    ensure => absent,
    require => Package["apache2"],
    notify => Service["apache2"]
  }

  apache::module { "ssl": }
  apache::module { "rewrite": conf => false }
  apache::module { "headers": conf => false }

}

# max_request_len limits the whole request size, and on newer versions defaults to only 128kb.
#                 We're setting it here to 5mb
class apache::fastcgi($max_processes = 1000, $max_processes_per_class = 100, $max_request_len = 5242880) {
  package { libapache2-mod-fcgid:
    ensure => latest,
    require => Package[apache2]
  }
  apache::module { "fcgid":
    require => Package["libapache2-mod-fcgid"]
  }
  file { "/etc/apache2/conf.d/fastcgi":
    content => template("apache/fastcgi.erb"),
    require => Package["apache2"],
    notify => Service["apache2"]
  }

}

class apache::passenger($instances_per_app = 4, $idle_time = 3600, $pool_size = 30,
$stat_throttle_rate = 1, $min_instances = 0, $spawn_method = "smart-lv2", $friendly_error_pages = false, $spawner_idle_time = 0) {

  apt::ppa { "passenger": ppa => "brightbox/passenger" }

  package { "libapache2-mod-passenger":
    ensure => installed,
    require => Package["apache2"]
  }

  file { "/etc/apache2/conf.d/passenger":
    content => template("apache/passenger.erb"),
    require => Package["libapache2-mod-passenger"],
    notify => Service["apache2"]
  }

  apache::module { "passenger":
    require => Package["libapache2-mod-passenger"]
  }
}
  
class apache::java {
  package { "libapache2-mod-jk":
    ensure => installed,
    require => Package["apache2"]
  }
  apache::module { "jk":
    conf => false,
    require => Package["libapache2-mod-jk"]
  }
  apache::module { "proxy": }
  apache::module { "proxy_ajp":
    conf => false,
    require => Apache::Module["jk"]
  }
}

class apache::weblogrotate {
  # Handles logrotation in /var/log/web/
  file { "/etc/logrotate.d/httpd-prerotate":
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => 755,
  }
  file { "/etc/logrotate.d/httpd-prerotate/web_rotate":
    ensure => present,
    owner  => root,
    group  => root,
    mode   => 700,
    content => "#!/bin/bash\n\n/usr/sbin/logrotate --state /var/lib/logrotate/webstatus /etc/logrotate.d/httpd-prerotate/web_rotate.conf",
  }
  file { "/etc/logrotate.d/httpd-prerotate/web_rotate.conf":
    ensure => present,
    owner  => root,
    group  => root,
    mode   => 644,
    content => template("apache/web_rotate.conf"),
  }
}
