require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'ruby::ruby19', :type => :class do
  it { should contain_package('ruby1.9.1') }
  it { should contain_package('ruby') }
  it { should contain_exec('update-alternatives-ruby1.9.1') }
end

describe 'ruby::ruby18', :type => :class do
  it { should contain_package('ruby1.8') }
  it { should contain_package('ruby') }
  it { should contain_exec('update-alternatives-ruby1.8') }
end
