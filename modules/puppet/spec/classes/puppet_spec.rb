require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'puppet::client', :type => :class do
  let(:params) { { :puppet_server => '@@server' } }

  it { should contain_package('puppet') }
  it { should contain_file('/etc/puppet/puppet.conf').
     with_content(/server=@@server/)
  }
end

describe 'puppet::master', :type => :class do
  let(:params) { { :fileserver_access => ["10.9.8.0/24", "172.5.0.0/16"] } }

  it { should contain_package('puppetmaster') }

  it { should contain_file('/etc/puppet/fileserver.conf').
    with_content(/allow 10.9.8.0\/24/).
    with_content(/allow 172.5.0.0\/16/)
  }
end
