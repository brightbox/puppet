require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'apt::ppa', :type => :define do
  let(:title) { 'brightbox-ruby-ng' }
  let(:params) { { :ppa => 'brightbox/ruby-ng3.3' } }
  let(:facts) { { :lsbdistcodename => 'precise' } }
  it { should contain_exec('apt-add-repository-brightbox-ruby-ng3_3').
   with( :creates => '/etc/apt/sources.list.d/brightbox-ruby-ng3_3-precise.list' )  
  }
end

describe 'apt::localpackage', :type => :define do
  let(:title) { 'elasticsearch' }
  let(:params) { { :repodir => '/some/path',
                  :url => 'https://github.com/downloads/elasticsearch/elasticsearch/elasticsearch-0.19.3.deb' } }
  it { should contain_exec('apt-localpackage-elasticsearch').
     with( :creates => '/some/path/elasticsearch-0.19.3.deb')
  }
end

describe 'apt::source', :type => :define do
  let(:title) { 'some-repo' }
  let(:params) { { 
                  :source => "deb http://some/url stable main",
                  :gpg_key_id => "0090DAAD"
                 } }
  it { should contain_file('/etc/apt/sources.list.d/some-repo.list').
     with_content(/deb http:\/\/some\/url/)
  }
  it { should contain_apt__key('some-repo0090DAAD').with_id('0090DAAD') }
end

describe 'apt::preferences', :type => :define do
  let(:title) { 'mypackage' }
  describe "default" do
    let(:params) { { :package => "somepackage", :pin => "version 99.8", :priority => 600 } }
    it { should contain_file("/etc/apt/preferences.d/mypackage").
        with_ensure("present").
        with_content(/Package: somepackage/)
    }
  end
  describe "disabled" do
    let(:params) { { :ensure => "absent", :package => "somepackage", :pin => "version 99.8", :priority => 600 } }
    it { should contain_file("/etc/apt/preferences.d/mypackage").
        with_ensure("absent")
    }
  end

end
