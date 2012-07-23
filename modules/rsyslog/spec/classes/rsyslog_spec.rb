require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'rsyslog', :type => :class do

  it { should_not contain_file('/var/log/by-host') }
  it { should contain_file('/etc/rsyslog.d/per_host_logs.conf').with(:ensure => :absent) }

  describe "remote_servers as csv" do
    let(:params) { { :remote_servers => "server_a,server_b" } }
    it { should contain_file('/etc/rsyslog.d/send-remote.conf').
      with_content(/@@server_a$/).
      with_content(/@@server_b$/)
    }
  end

  describe "remote_servers as array" do
    let(:params) { { :remote_servers => ["server_a","server_b"] } }
    it { should contain_file('/etc/rsyslog.d/send-remote.conf').
      with_content(/@@server_a$/).
      with_content(/@@server_b$/)
    }
  end

  describe "per_host_logs" do
    let(:params) { { :per_host_logs => true } }
    it { should contain_file('/etc/rsyslog.d/per_host_logs.conf').
      with_content(/FileNamePerHost/)
    }
    it { should contain_file('/var/log/by-host') }
    it { should contain_file('/etc/logrotate.d/rsyslog-by-host') }
  end
end

