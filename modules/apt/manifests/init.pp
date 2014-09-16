class apt (
  $refreshonly = hiera("apt.refreshonly", true),
  $autoupgrade = hiera("apt.autoupgrade", false)
) {
  package { "python-software-properties":
    ensure => installed
  }
  exec { "apt-update":
    command => "/usr/bin/apt-get update",
    refreshonly => $refreshonly
  }

  exec { "apt-upgrade":
    command => "/usr/bin/apt-get -y upgrade",
    refreshonly => true
  }

  if $autoupgrade {
    Exec["apt-update"] ~> Exec["apt-upgrade"]
  }

  # Ensure apt is setup before running apt-get update
  Apt::Ppa <| |> -> Exec["apt-update"]
  Apt::Key <| |> -> Exec["apt-update"]

  # Ensure apt-get update has been run before installing any packages
  Exec["apt-update"] -> Package <| |>
}

# Sets up a local apt repository, ready for using with apt::localpackage
class apt::localrepo($repodir = "/var/cache/local-repo") {
  file { "${repodir}":
    ensure => directory,
    mode => 755,
    notify => Exec[apt-update-local-repo]
  }
  exec { "apt-update-local-repo":
    cwd => $repodir,
    command => "/usr/bin/apt-ftparchive packages . > Packages",
    require => [File["${repodir}"]],
    before => Exec["apt-update"],
    notify => Exec["apt-update"],
    refreshonly => true
  }
  apt::source { "apt-local-repo":
    source => "deb [trusted=yes] file:${repodir} /",
  }
}

# Defines a deb package to download and put into the local apt repository.
# Requires that you set a url
define apt::localpackage($url = "", $repodir = "/var/cache/local-repo") {
  $url_tokens = split($url, '/')
  $pkg_filename = $url_tokens[-1]
  exec { "apt-localpackage-${name}":
    command => "/usr/bin/curl -L -s -C - -O $url",
    cwd => $repodir,
    creates => "${repodir}/${pkg_filename}",
    notify => Exec["apt-update-local-repo"],
    require => File[$repodir]
  }
}

# $name is arbitrary. attribute "ppa" should be the ppa name, such as
# "brightbox/ruby-ng" (this is due to a bug in puppet with resources
# with slashes in them)
define apt::ppa($ppa = "") {
  exec { "apt-add-repository-$ppa":
    command => "/usr/bin/apt-add-repository ppa:$ppa",
    creates => ppa_filename($ppa),
    notify => Exec["apt-update"],
  }
}

# $name is arbitrary. attribute "repository" should be the repository name, such as
# "ppa:brightbox/ruby-ng" (this is due to a bug in puppet with resources
# with slashes in them)
# this is a more advanced version of apt:ppa, which supports the (much less common)
# cloud-archive: type
define apt::repository($repository = "") {
  $repository_name = apt_repository_name($repository)
  exec { "apt-add-repository-$repository_name":
    command => "/usr/bin/apt-add-repository '$repository'",
    creates => "/etc/apt/sources.list.d/${repository_name}.list",
    unless  => "/bin/egrep '^${repository}' /etc/apt/sources.list",
    notify  => Exec[apt-update],
  }
}


# id should be the 8 character hex string that represents the key (is
# actually the last 8 characters of the fingeprint)
define apt::key($id) {
  exec { "apt-key-$name":
    command => "/usr/bin/apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys $id",
    unless => "/usr/bin/apt-key list | /bin/grep $id",
    notify => Exec["apt-update"]
  }
}

# name should be a nice key, like percona, or brightbox
# source should be: "deb url $lsbdistcodename main"
# gpg_key_id is a gpg key to import, can be left empty
define apt::source($source = "", $gpg_key_id = "") {
  file { "/etc/apt/sources.list.d/${name}.list":
    content => "# This file is managed by Puppet\n$source",
    notify => Exec["apt-update"]
  }

  if $gpg_key_id {
    # Allow multiple definitions of same key - it's not a problem and
    # could be a common ocurrence
    apt::key { "${name}${gpg_key_id}": id => $gpg_key_id }
    Apt::Key["${name}${gpg_key_id}"] -> File["/etc/apt/sources.list.d/${name}.list"]
  }
}

# Adapted from https://github.com/camptocamp/puppet-apt primarily to
# support their postgresql recpie.
define apt::preferences($ensure="present", $package="", $pin, $priority) {
  $pkg = $package ? {
    "" => $name,
    default => $package,
  }

  $fname = regsubst($name, '\.', '-', 'G')

  file {"/etc/apt/preferences.d/$fname":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    mode    => 644,
    content => template("apt/preferences.erb"),
    before  => Exec["apt-update"],
    notify  => Exec["apt-update"],
  }
}
