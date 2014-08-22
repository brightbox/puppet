# xcache_size is an integer, to represent megabytes of ram to be used
class apache::php($max_processes = 3) {

  include apache::fastcgi
  include ::php

  file { "/etc/apache2/conf.d/php-fastcgi":
    content => template("apache/php-fastcgi.erb"),
    require => [Package[php5-cgi], Package["apache2"], Apache::Module[fcgid]],
    notify  => Service["apache2"]
  }
}

class apache::php::memcached_sessions(
  $memcached_hosts        = ["tcp://127.0.0.1:11211"],
  $session_redundancy     = 2,
  $session_gc_maxlifetime = 1440
  ) {

  $config_filename = $::lsbdistcodename ? {
    'precise' => '/etc/php5/conf.d/memcache.ini',
    'raring'  => '/etc/php5/mods-available/memcache.ini',
    'trusty'  => '/etc/php5/mods-available/memcache.ini'
  }

  file { "apache-php-memcache.ini":
    path => $config_filename,
    content => template("apache/memcache.ini.erb"),
    require => [Package["php5-memcache"], Package["apache2"]],
    notify => Service["apache2"]
  }
  file { "/etc/php5/conf.d/memcache_sessions.ini":
      content => template("apache/memcache_sessions.ini.erb"),
      require => [Package["php5-memcache"], Package["apache2"]],
      notify => Service["apache2"]
  }

}
