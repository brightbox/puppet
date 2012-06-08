require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'apache::modsecurity', :type => :class do
  let(:params) { { :datadir => '/some/path' } }
  it { should contain_file('/etc/apache2/conf.d/modsecurity').
    with_content(/\/some\/path/)
  }
  it { should contain_file('/some/path').with_ensure('directory') }
  it { should contain_file('/etc/apache2/mods-enabled/mod-security.load') }
end
