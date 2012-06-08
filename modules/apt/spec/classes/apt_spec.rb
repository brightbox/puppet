require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'apt', :type => :class do
  it { should contain_exec('apt-update') }
end

describe 'apt::localrepo', :type => :class do
end
