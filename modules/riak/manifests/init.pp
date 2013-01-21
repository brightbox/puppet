# set $cookie to a shared secret between all nodes on the cluster (this
# is the distributed erlang cookie)
#
# TODO: ssl
#
#
# Set $seed_host to the IP of another host in the cluster to have
# puppet issue a !riak-admin join" command for. Leave as false to do
# nothing. This command will be run only once for the defined seed
# host. If you change the $seed_host option, it will re-run it on the
# next puppet run.
#
# $riak_search controls the riak search feature
#
# $riak_control controls the riak admin panel
#
# If $riak_control is enabled, $riak_control_userlist should be an array
# of : separated username and passwords, e.g: ["user1:password",
# "user2:password"]


class riak($cookie = "secret", $seed_host = false, $riak_search = true, $riak_control = false, $riak_control_userlist = []) {
  apt::source { "basho":
    source => "deb http://apt.basho.com $::lsbdistcodename main",
    gpg_key_id => "DDF2E833"
  }

  # libssl0.9.8 is apparently needed but not a pkg dependency
  package { "libssl0.9.8":
    ensure => installed
  }
  package { "riak":
    ensure => installed,
    require => Package["libssl0.9.8"]
  }

  file { "/etc/riak/vm.args":
    content => template("riak/vm.args.erb"),
    require => Package[riak],
    notify => Service[riak]
  }

  file { "/etc/riak/app.config":
    content => template("riak/app.config.erb"),
    require => Package[riak],
    notify => Service[riak]
  }

  service { "riak":
    ensure => running,
    require => File["/etc/riak/app.config", "/etc/riak/vm.args"]
  }

  if $seed_host {
    exec { "riak-seed-host":
      path => "/usr/sbin:/usr/bin",
      command => "riak-admin cluster join riak@$seed_host && riak-admin cluster plan && riak-admin cluster commit && touch /var/lib/riak/joined-seed-host-${seed_host}",
      creates => "/var/lib/riak/joined-seed-host-${seed_host}",
      require => Service[riak]
    }
  }

}
