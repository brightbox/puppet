require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'elasticsearch', :type => :class do
  describe "with a version" do
    let(:params) { { :version => "0.20.2" } }
    it { should contain_package('elasticsearch').
       with_ensure('0.20.2')
    }
    it { should contain_apt__localpackage("elasticsearch").
       with_url(/elasticsearch-0.20.2.deb$/)
    }
  end

  describe "with a version and a deburl" do
    let(:params) { { :version => "0.30.3", :deburl => "https://somehost/elasticsearch.deb" } }
    it { should contain_package('elasticsearch').
       with_ensure('0.30.3')
    }
    it { should contain_apt__localpackage("elasticsearch").
       with_url("https://somehost/elasticsearch.deb")
    }
  end

  describe "config file" do
    let(:params) { { :discovery_hosts => ["s_one", "s_two", "s_three"] } }
    it { should contain_file('/etc/elasticsearch/elasticsearch.yml').
       with_content(/["s_one", "s_two", "s_three"]/)
    }
  end

end

describe 'elasticsearch::nrpe', :type => :class do
  it { should contain_nagios__nrpe_config('elasticsearch') }
end
