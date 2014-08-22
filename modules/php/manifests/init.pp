# module for configuring php on ubuntu
# memory_limit is in megabytes
# max_input_time is in seconds
# max_execution_time is in seconds
# upload_max_filesize is in megabytes
# max_file_uploads in in megabytes
class php(
  $memory_limit = 128, $max_input_time = 60, $max_execution_time = 30,
  $upload_max_filesize = 10, $max_file_uploads = 20
  ) {

  package { ['php5-cgi', 'php5-common', 'php5-curl', 'php5-gd', 
             'php5-mcrypt', 'php5-memcache', 'php5-mysql', 'php5-cli']:
               ensure => installed
  }

  # Make trusty act like raring/precise etc.
  if $::lsbdistrelease >= 14.04 {
    file { '/etc/php5/conf.d':
      ensure  => link,
      target  => '/etc/php5/cgi/conf.d',
      require => Package["php5-cgi"],
    }
  }

  file { '/etc/php5/conf.d/base.ini':
    content => template('php/base.ini.erb'),
    require => Package['php5-common']
  }

}
