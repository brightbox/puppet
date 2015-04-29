class sysctl {
  exec { "start-procps":
    command => "/sbin/start procps",
    refreshonly => true
  }
}

define sysctl::config($content = "") {
  if !defined(Exec["start-procps"]) {
    include sysctl
  }

  file { "/etc/sysctl.d/60-puppet-$name.conf":
    content => "${content}\n",
    notify => Exec["start-procps"]
  }
}
  

# shmmax is 32MB by default
class sysctl::kernel($shmmax = 33554432) {
  sysctl::config { "kernel":
    content => "kernel.shmmax=$shmmax"
  }
}

class sysctl::tcp($keepalive_time = 30, $keepalive_probes = 2, $keepalive_intvl = 10) {
  sysctl::config { "tcp":
    content => "
net.ipv4.tcp_keepalive_time=$keepalive_time
net.ipv4.tcp_keepalive_probes=$keepalive_probes 
net.ipv4.tcp_keepalive_intvl=$keepalive_intvl
"
  }
}
