require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'nagios::nrpe_config', :type => :define do
  let(:title) { 'somecheck' }
  let(:params) { { :content => 'command[bleh]=/path/to/command' } }
# FIXME: figure out how to setup tags before testing
#  it { should contain_file('/etc/nagios/nrpe.d/somecheck').
#   with( 
#        :content => 'command[bleh]=/path/to/command'
#       )  
#  }
end
