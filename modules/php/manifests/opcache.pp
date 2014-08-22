class php::opcache( $enable = true, $opcache_size = 64, $max_files = 4000, $revalidate_freq = 2 ) {
  if $::lsbdistrelease < 14.04 {
    fail('php::opcache not supported before trusty')
  }
  file { '/etc/php5/conf.d/puppet-opcache.ini':
    content => template('php/opcache.ini.erb'),
    require => Package["php5-common"],
    notify  => Service["apache2"]
  }

}
