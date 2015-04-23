class percona::params {
  $innodb_buffer_pool_size = ($::memorysizeinbytes / 1024 / 1024) * 0.60
  $key_buffer_size = ($::memorysizeinbytes / 1024 / 1024) * 0.05
  $data_dir = "/var/lib/mysql"
}
