require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'cloud-sql-default' do
  let(:facts) { { :memorysizeinbytes => 1024 * 1024 * 1024 } }
  it { should contain_mysql_user("admin@%").with_password_hash("*E43841DF91E2EF25FD52CC5CD5319663731847EA") }
  it { should contain_cron("unattended_upgrade").
               with_hour(10).
               with_weekday(5)
  }
  it { should contain_service("puppet").with_ensure("stopped").with_enable(false) }
  it { should contain_file("domtrix-config").
               with_path("/etc/domtrix/config.yml").
               with_content(/mq_password: mqpw/).
               with_content(/mq_login: mqu/)
  }
end

describe 'cloud-sql-5-6' do
  let(:facts) { { :memorysizeinbytes => 1024 * 1024 * 1024 } }
  it { should contain_class("mys_service") }
  it { should contain_class("percona::server::5_6") }
end

describe 'cloud-sql-5-5' do
  let(:facts) { { :memorysizeinbytes => 1024 * 1024 * 1024 } }
  it { should contain_class("mys_service") }
  it { should contain_class("percona::server::5_5") }
end


