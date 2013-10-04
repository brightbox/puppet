require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'account', :type => :define do
  let(:title) { 'mario' }
  let(:params) { { :uid => '15000', :authorized_keys => ["ssh-key bleh root@localhost"], :home => "/srv/home/mazzer" } }
  it { should contain_user('mario').with_uid(15000) }
  it { should contain_user('mario').with_gid(15000) }
  it { should contain_user('mario').with_home('/srv/home/mazzer') }
  it { should contain_group('mario').with_gid(15000) }
  it { should contain_file('/srv/home/mazzer/.ssh/authorized_keys').with_content("# Managed by puppet\nssh-key bleh root@localhost") }
end
