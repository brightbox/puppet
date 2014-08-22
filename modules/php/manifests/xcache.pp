# module to install and configure php accelerator, xcache
# xcache_size is megabytes
class php::xcache($xcache_size = 64) {

  if $::lsbdistrelease >= 14.04 {
    notice('xcache not supported (or needed) on trusty or above')
  } else {

  package { 'php5-xcache':
    ensure => installed
  }
  $xcache_config_path = $::lsbdistcodename ? {
    'precise' => '/etc/php5/conf.d/xcache.ini',
    'raring'  => '/etc/php5/mods-available/xcache.ini',
  }
  $xcache_so_path = $::lsbdistcodename ? {
    'precise' => '/usr/lib/php5/20090626/xcache.so',
    'raring'  => '/usr/lib/php5/20100525+lfs/xcache.so',
  }

  file { 'xcache.ini':
    path    => $xcache_config_path,
    content => template('php/xcache.ini.erb'),
    require => [Package["php5-xcache"], Package["apache2"]],
    notify  => Service["apache2"]
  }

  }
}
