node "puppet-rspec.syslog.server" {
  class { "brightbox::base": syslog_client => false }
  include apt
 
  include brightbox::syslog::server
}

node "puppet-rspec.syslog.client" {
  include brightbox::base
  include apt
}
