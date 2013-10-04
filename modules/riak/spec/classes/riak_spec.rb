require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'riak', :type => :class do

  describe "default" do
    let(:facts) { { :lsbdistcodename => 'precise', :ipaddress => '10.11.12.13' } }
    it { should contain_package("riak").
      with_ensure("installed")
    }
    it { should contain_file("/etc/riak/vm.args").
      with_content(/-name riak@10.11.12.13/)
    }
    it { should contain_file("/etc/riak/app.config").
      with_content(/\{riak_search, \[\{enabled, true\}\]/).
      with_content(/\{riak_control, \[\{enabled, false/).
      with_content(/\{userlist, \[\]}/)
    }
  end

  describe "with cookie" do
    let(:params) { { :cookie => "thisistheriakcookie" } }
    let(:facts) { { :lsbdistcodename => 'precise', :ipaddress => '10.11.12.13' } }
    it { should contain_file("/etc/riak/vm.args").
      with_content(/-setcookie thisistheriakcookie/)
    }
  end

  describe "with riak_search disabled" do
    let(:params) { { :riak_search => false } }
    let(:facts) { { :lsbdistcodename => 'precise', :ipaddress => '10.11.12.13' } }
    it { should contain_file("/etc/riak/app.config").
      with_content(/\{riak_search, \[\{enabled, false\}\]/)
    }
  end

  describe "with seed_host" do
    let(:params) { { :seed_host => "14.15.16.17" } }
    let(:facts) { { :lsbdistcodename => 'precise', :ipaddress => '10.11.12.13' } }
    it { should contain_exec("riak-seed-host").
      with_command(/join riak@14.15.16.17/)
    }
  end
  describe "with riak_control" do
    let(:params) { { :riak_control => true, :riak_control_userlist => ["john:secret", "bob:hidden"] } }
    let(:facts) { { :lsbdistcodename => 'precise', :ipaddress => '10.11.12.13' } }
    it { should contain_file("/etc/riak/app.config").
      with_content(/\{riak_control, \[\{enabled, true/).
      with_content(/\{userlist, \[\{"john", "secret"\},\{"bob", "hidden"\}\]\}/)
    }
  end
end

