require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'apache', :type => :class do
  let(:params) { { :http_ports => [80,81] } }
  it { should contain_package('apache2').
    with_name('apache2-mpm-event').
    with_ensure('installed')
  }
  it { should contain_file('/etc/apache2/ports.conf').
    with_content(/Listen 80/).
    with_content(/Listen 81/)
  }
end

describe 'apache::passenger', :type => :class do
  let(:params) { { :idle_time => 7200, :pool_size => 15 } }
  it { should contain_package('libapache2-mod-passenger').with_ensure('installed') }
  it { should contain_file('/etc/apache2/conf.d/passenger').
    with_content(/PassengerPoolIdleTime 7200/).
    with_content(/PassengerMaxPoolSize 15/)
  }
end
