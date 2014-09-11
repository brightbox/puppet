# setup a directory struction for a rails app
# requires that user www-data user exists, which is usually does
define rails::skeleton($owner, $path = "/home/${owner}/${name}", $group = 'www-data') {
  file { $path:
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => '0710'
  }
  file { ["${path}/shared", "${path}/releases", "${path}/tmp"]:
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => '0710'
  }
  file { ["${path}/shared/log", "${path}/shared/config"]:
    ensure  => directory,
    owner   => $owner,
    group   => $owner,
    mode    => '0750',
    require => File["${path}/shared"]
  }
}

# define an apache config for an https site serving a rails app, using
# passenger
define rails::apache::https($owner, $domain, $rails_root = "/home/${owner}/${name}/current", $port = 443, $certificate_chain_file = '') {

  apache::site { "rails-${name}":
    content => template('rails/apache-https.conf.erb'),
    require => Class[Apache::Passenger]
  }

}
