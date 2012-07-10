require File.join(File.dirname(__FILE__), '../spec_helper')

describe "nagios::nrpe", :type => :class do
  let(:params) { { :allowed_hosts => ["@host1", "@host2"] } }
  it { should contain_package("nagios-nrpe-server") }
  it { should contain_file("/etc/nagios/nrpe.cfg").
     with_content(/@host1,@host2/).
     with_content(/include.*nrpe_puppet.cfg/)
  }
end
