# Internal use only. Can only be used on server versions confirmed to
# support auth socket!
class percona::server::auth_socket {
  file { "/etc/mysql/conf.d/auth_socket.cnf":
    content => "[mysqld]\nplugin-load=auth_socket.so\n",
    require => File["/etc/mysql/my.cnf"]
  }
}
