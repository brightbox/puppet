require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'upstart', :type => :class do
  describe "with user_jobs (default)" do
    it { should contain_file('/etc/dbus-1/system.d/Upstart.conf').
      with_source(/Upstart.conf.user-jobs$/)
    }
  end

  describe "without user_jobs" do
    let(:params) { { :user_jobs => false } }
    it { should contain_file('/etc/dbus-1/system.d/Upstart.conf').
      with_source(/Upstart.conf.standard$/)
    }
  end
end

