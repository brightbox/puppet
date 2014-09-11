require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'rails::skeleton', :type => :define do
  let(:title) { 'twitter' }
  let(:params) { { :owner => 'brian' } }
  it { should contain_file('/home/brian/twitter') }
end

describe 'rails::apache::https', :type => :define do
  let(:title) { 'twitter' }
  let(:params) { { :owner => 'john', :domain => 'twitter.com', :port => '88888' } }
  it { should contain_apache__site('rails-twitter').
     with_content(/DocumentRoot \/home\/john\/twitter\/current\/public/).
     with_content(/VirtualHost \*\:88888/)
  }
end
