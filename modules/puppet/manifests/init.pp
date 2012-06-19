# Ubuntu specific
class puppet::client($enable = true, $puppet_server = "") {

	package { "puppet":
		ensure => installed
  }

  service { "puppet":
    ensure => $enable,
    enable => $enable,
    hasstatus => true,
		hasrestart => true,
    require => Package["puppet"]
  }

  file { "/etc/puppet/puppet.conf":
    ensure => file,
    content => template("puppet/client-puppet.conf.erb"),
    require => Package["puppet"],
    notify => Service["puppet"]
  }

  file { "/etc/default/puppet":
    ensure => file,
    content => "START=yes",
    require => Package["puppet"],
    before => Service["puppet"]
  }
  
}

#
# Provides a puppetmaster configured with staging and production
# environments.
#
# Push a git repo with master and production brances to
# puppet@hostname:puppet.git and they'll be auto-deployed to
# /etc/puppet (overwriting any local changes!)
#
# Configure access to the git repo with ssh keys in puppet users home
# dir (/var/lib/puppet)
#
# $fileserver_access should be a list of IPs/networks as required by
# fileserver.conf
#
# $certificate_name specifies the name of the ssl certificate and key
# for the master, e.g: /var/lib/puppet/ssl/certs/$certificate_name
# Defaults to fqdn.pem - you need to manually create and sign a new
# cert if you want to use a different hostname
#
# Only needs a database config if $store_configs is set to true
#
# 
class puppet::master($store_configs = false, $db_server = "", $db_user = "", $db_password = "", $db_adapter = "", $fileserver_access = [], $certificate_name = "${fqdn}.pem") {

  $gitrepo = "/var/lib/puppet/puppet.git"
  
  package { ["puppetmaster", "puppetmaster-passenger"]:
    ensure => latest
  }

  user { "puppet":
    shell => "/usr/bin/git-shell",
    require => Package["puppetmaster"]
  }

  service { "puppetmaster":
    ensure => false,
    enable => false,
    require => Package[puppetmaster]
  }

  file { "/etc/puppet":
    ensure => directory,
    owner => puppet,
    group => puppet,
    mode => 755,
    require => Package[puppetmaster]
  }
  
  file { "/etc/puppet/puppet.conf":
    ensure => file,
    content => template("puppet/master-puppet.conf.erb"),
    require => File["/etc/puppet"]
  }
  file { "/etc/puppet/fileserver.conf":
    ensure => file,
    content => template("puppet/master-fileserver.conf.erb"),
    require => File["/etc/puppet"]
  }

  file { ["/etc/puppet/production", "/etc/puppet/staging"]:
    ensure => directory,
    owner => puppet,
    group => puppet,
    mode => 755,
    require => File["/etc/puppet"]
  }

  # FIXME: should use proper nginx class once we provide one!
  apt::ppa { "nginx": ppa => "brightbox/passenger-nginx" }
  
  package { "nginx":
    name => "nginx-full",
    ensure => installed
  }

  service { "nginx":
    ensure => true,
    enable => true,
    hasstatus => true,
    hasrestart => true
  }

  package { "rubygems": ensure => installed }

  file { "/etc/nginx/sites-enabled/puppetmaster":
    ensure => file,
    content => template("puppet/nginx-site.conf.erb"),
    require => Package[nginx],
    notify => Service[nginx]
  }

  file { "/etc/nginx/conf.d/passenger.conf":
    ensure => file,
    content => "passenger_root /usr/lib/phusion-passenger;",
    require => Package[nginx],
    notify => Service[nginx]
  }

  package { "git-core": ensure => installed }

  # init the git repo
  exec { "init-puppet-repo":
    path => "/usr/bin",
    user => puppet, group => puppet,
    command => "git init --bare $gitrepo",
    creates => "$gitrepo",
    require => [Package[git-core], Package[puppetmaster]]
  }

  file { "${gitrepo}/hooks/post-receive":
    content => template("puppet/git-post-receive-hook.sh"),
    mode => 750,
    owner => puppet, group => puppet,
    require => Exec["init-puppet-repo"]
  }
      
}
