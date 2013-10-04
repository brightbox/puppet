class ssl {
	package { "openssl":
    ensure => installed
  }
  package { "ssl-cert":
    ensure => installed
  }
  file { "/etc/ssl":
    ensure => directory,
    require => Package[openssl]
  }
  file { ["/etc/ssl/private"]:
    ensure => directory,
    mode => 751,
    require => File["/etc/ssl"]
  }

  file { ["/etc/ssl/certs", "/etc/ssl/reqs"]:
    ensure => directory,
    require => File["/etc/ssl"]
  }

  file { "/etc/ssl/ssl-cert-snakeoil.pem":
    ensure => present,
    require => Package[ssl-cert]
  }

  file { "/etc/ssl/private/ssl-cert-snakeoil.key":
    ensure => present,
    require => Package[ssl-cert]
  }
}

# FIXME: hostname
define ssl::cert::selfsigned($state, $country, $organisation, $days = 3650, $keybits = 1024, $owner = root, $group = root) {
  include ssl

  $key_filename = "/etc/ssl/private/${name}.key"
  $req_filename = "/etc/ssl/reqs/${name}.csr"
  $crt_filename = "/etc/ssl/certs/${name}.crt"

  # FIXME: name or keybits may not be safe to use in a command
  exec { "${key_filename}-genrsa":
    path => "/usr/bin",
    command => "openssl genrsa -out ${key_filename} ${keybits}",
    creates => $key_filename,
    require => [File["/etc/ssl/private"], Package[openssl]]
  }

  file { $key_filename:
    owner => $owner, group => $group,
    mode => 640,
    require => Exec["${key_filename}-genrsa"]
  }

  exec { $req_filename:
    path => "/usr/bin",
    command => "openssl req -new -days $days -batch -subj '/C=${country}/ST=${state}/O=${organisation}/' -key ${key_filename} -out ${req_filename}",
    creates => $req_filename,
    require => [File[$key_filename], Package[openssl], File["/etc/ssl/reqs"]]
  }

  exec { "${crt_filename}-x509":
    path => "/usr/bin",
    command => "openssl x509 -req -days ${days} -in ${req_filename} -signkey ${key_filename} -out ${crt_filename}",
    creates => $crt_filename,
    require => [Exec[$req_filename], File["/etc/ssl/certs"], Package[openssl]]
  }

  file { $crt_filename:
    owner => $owner, group => $group,
    mode => 644,
    require => Exec["${crt_filename}-x509"]
  }

}

# name should be the domain usually
# cert and key should be strings with the cert and key data
define ssl::cert($cert = hiera("${name}.crt"), $key = hiera("${name}.key"), $owner = root, $group = root) {
  include ssl
  $key_filename = "/etc/ssl/private/${name}.key"
  $crt_filename = "/etc/ssl/certs/${name}.crt"

  file { $key_filename:
    owner => $owner,
    group => $group,
    mode => 640,
    content => $key
  }

  file { $crt_filename:
    owner => $owner, group => $group,
    mode => 644,
    content => $cert
  }
}
