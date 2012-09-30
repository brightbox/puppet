require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'apache::site', :type => :define do
  let(:title) { 'myweb' }
  describe "with content" do
    let(:params) { { :content => '@@myconfig' } }
    it { should contain_file("/etc/apache2/sites-available/myweb").
      with(:content => '@@myconfig').
      with(:source => nil)
    }
    it { should contain_file("/etc/apache2/sites-enabled/myweb").
      with(:ensure => "/etc/apache2/sites-available/myweb")
    }
  end
  describe "with source" do
    let(:params) { { :source => '@@mysource' } }
    it { should contain_file("/etc/apache2/sites-available/myweb").
      with(:source => '@@mysource').
      with(:content => nil)
    }
    it { should contain_file("/etc/apache2/sites-enabled/myweb").
      with(:ensure => "/etc/apache2/sites-available/myweb")
    }
  end

  
end
