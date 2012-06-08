require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'apt::ppa', :type => :define do
  let(:title) { 'brightbox-ruby-ng' }
  let(:params) { { :ppa => 'brightbox/ruby-ng' } }
  let(:facts) { { :lsbdistcodename => 'precise' } }
  it { should contain_exec('apt-add-repository-brightbox-ruby-ng').
   with( :creates => '/etc/apt/sources.list.d/brightbox-ruby-ng-precise.list' )  
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
