# discovery_hosts should be a an array of hostnames or IPs of other masters
#
# Will automatically download debs for versions >= 0.19.  For older
# versions, you must provide a url to the appropriate deb file using
# the deburl parameter (you still need to provide the right $version
# parameter too).
#
# To run a client-only server, set $master and $data to false
#
# On Lucid it currently requires a manual step to install the package
# as Lucid apt-get doesn't support trusted=yes parameter
#
class elasticsearch(
  $version = hiera("elasticsearch.version", "0.19.3"),
  $heap_size = hiera("elasticsearch.heap_size", "1024m"),
  $cluster_name = hiera("elasticsearch.cluster_name", "elasticsearch"),
  $discovery_hosts = hiera("elasticsearch.discovery_hosts", []),
  $minimum_master_nodes = hiera("elasticsearch.minimum_master_nodes", 1),
  $deburl = hiera("elasticsearch.deburl", false),
  $master = hiera("elasticsearch.master", true),
  $data = hiera("elasticsearch.data", true)
) {
  package { "default-jre-headless":
    ensure => installed
  }
  apt::localpackage { "elasticsearch":
    url => $deburl ? {
      false => "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${version}.deb",
      default => $deburl
    }
  }
  package { "elasticsearch":
    ensure => $version
  }
  service { "elasticsearch":
    ensure => true,
    enable => true,
    require => Package[elasticsearch],
    hasstatus => true,
    hasrestart => true
  }
  file { "/etc/default/elasticsearch":
    content => template("elasticsearch/default-elasticsearch.erb"),
    notify => Service[elasticsearch]
  }
  file { "/etc/elasticsearch":
    ensure => directory,
    require => Package[elasticsearch]
  }
  file { "/etc/elasticsearch/elasticsearch.yml":
    content => template("elasticsearch/elasticsearch.yml.erb"),
    notify => Service[elasticsearch],
    require => [Package[elasticsearch], File["/etc/elasticsearch"]]
  }
  file { "/etc/elasticsearch/logging.yml":
    content => template("elasticsearch/logging.yml.erb"),
    notify => Service[elasticsearch],
    require => [Package[elasticsearch], File["/etc/elasticsearch"]]
  }
  if tagged("nrpe") {
    include elasticsearch::nrpe
  }
}

class elasticsearch::apacheproxy($server_name = "elasticsearch", $htpasswd_filename = "/etc/apache2/elasticsearch.htpasswd") {
  apache::site { "elasticsearch":
    content => template("elasticsearch/elasticsearch-apache.conf.erb")
  }
  apache::module { 'proxy': conf => false }
  apache::module { 'proxy_http': conf => false }
}

class elasticsearch::nrpe {
  nagios::nrpe_config { "elasticsearch":
    content => template("elasticsearch/es-nrpe.conf.erb")
  }
}
