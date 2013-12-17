require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'percona::server::base', :type => :class do
  let(:params) { { 
    :root_password => "test"
  } }
  let(:facts) { {
      :memorysizeinbytes => 1024 * 1024 * 1024
    } }

  # calculated from memorysizeinbytes
  it { should contain_file('/etc/mysql/conf.d/base.cnf').
    with_content(/innodb_buffer_pool_size = 716M/).
    with_content(/key_buffer = 51M/)
  }

  context "with replication settings" do
    let(:params) { {
        :root_password => "test",
        :server_id => 1,
        :max_servers => 2,
      } }
    it { should contain_file('/etc/mysql/conf.d/base.cnf').
      with_content(/server-id = 1/).
      with_content(/log_bin = binlog/).
      with_content(/auto_increment_increment = 2/)
    }
  end

  context "with innodb_buffer_pool_size" do
    let(:params) { { :root_password => "test", :innodb_buffer_pool_size => 99999 } }
    it { should contain_file('/etc/mysql/conf.d/base.cnf').
      with_content(/innodb_buffer_pool_size = 99999M/)
    }
  end

  context "with ssl" do
    let(:params) { { :root_password => "test", :ssl => true } }
    it { should contain_file('/etc/mysql/conf.d/ssl.cnf').
      with_content(/ssl-cert.*ssl-cert-snakeoil.pem/).
      with_content(/ssl-key.*ssl-cert-snakeoil.key/)
    }
  end

  context "with ssl custom cert and key" do
    let(:params) { { :root_password => "test", :ssl => true, :ssl_cert => "@@mycert", :ssl_key => "@@mykey" } }
    it { should contain_file('/etc/mysql/conf.d/ssl.cnf').
      with_content(/ssl-cert = @@mycert/).
      with_content(/ssl-key = @@mykey/)
    }
  end

  context "with auth_socket support" do
    let(:pre_condition) { 'include percona::server::5_5' }
    let(:params) { { } }
    it { should contain_class("Percona::Server::Auth_socket") }
    it { should contain_file('/etc/mysql/conf.d/auth_socket.cnf').
      with_content(/auth_socket.so/)
    }
    it { should contain_mysql_user('root@localhost').
      with_password_hash(nil).
      with_identified_with('auth_socket')
    }
    it { should_not contain_file("/etc/my.cnf") }
  end

  context "without auth_socket support and no root_password" do
    let(:pre_condition) { 'include percona::server::5_1' }
    let(:params) { { } }
    it { should_not contain_class("Percona::Server::Auth_socket") }
    it { should_not contain_file('/etc/mysql/conf.d/auth_socket.cnf') }
    it { should contain_mysql_user('root@localhost').
      with_require(/Class\[Percona::Server::Auth_socket\]/)
    }
  end

  context "without auth_socket support and with a root_password" do
    let(:params) { { :root_password => "passywordy" } }
    it { should_not contain_file('/etc/mysql/conf.d/auth_socket.cnf') }
    it { should contain_mysql_user('root@localhost').
      with_identified_with(nil).
      with_password_hash("*7EA51985D52ABC0DC581872B97955A167521D59C")
    }
    it { should contain_file("/etc/my.cnf").
      with_content(/passywordy/)
    }
  end

end
