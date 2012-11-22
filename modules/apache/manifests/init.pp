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


class apache($http_ports = [80]) {
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

  file { "/var/log/web":
    ensure => directory
  }

  file { ["/etc/apache2/sites-enabled/000-default", "/etc/apache2/sites-enabled/default", "/etc/apache2/sites-enabled/default-ssl"]:
    ensure => absent,
    require => Package["apache2"],
    notify => Service["apache2"]
  }

  apache::module { "ssl": }
  apache::module { "rewrite": conf => false }
  apache::module { "headers": conf => false }

}

class apache::fastcgi {
  package { libapache2-mod-fcgid:
    ensure => latest
  }
  apache::module { "fcgid":
    require => Package["libapache2-mod-fcgid"]
  }

}
class apache::php {

  include apache::fastcgi
  
  package { [php5-cgi, php5-common, php5-curl, php5-gd, php5-mcrypt, php5-memcache, php5-mysql]:
    ensure => latest
  }

  file { "/etc/apache2/conf.d/php-fastcgi":
    content => template("apache/php-fastcgi.erb"),
    require => [Package[php5-cgi], Package["apache2"], Apache::Module[fcgid]],
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
