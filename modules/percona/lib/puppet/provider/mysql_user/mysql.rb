require 'puppet/provider/package'

Puppet::Type.type(:mysql_user).provide(:mysql,
		# T'is funny business, this code is quite generic
		:parent => Puppet::Provider::Package) do

	desc "Use mysql as database."
	optional_commands :mysql => '/usr/bin/mysql'
	optional_commands :mysqladmin => '/usr/bin/mysqladmin'

	# retrieve the current set of mysql users
	def self.instances
		users = []

		cmd = "#{command(:mysql)} mysql -NBe 'select concat(user, \"@\", host), password, plugin as identified_with from user'"
		execpipe(cmd) do |process|
			process.each do |line|
				users << new( query_line_to_hash(line) )
			end
		end
		return users
	end

	def self.query_line_to_hash(line)
		fields = line.chomp.split(/\t/)
		{
			:name => fields[0],
			:password_hash => fields[1],
      :identified_with => fields[2],
			:ensure => :present
		}
	end

	def mysql_flush 
		mysqladmin "flush-privileges"
	end

	def query
		result = {}

		cmd = "#{command(:mysql)} -NBe 'select concat(user, \"@\", host), password from user where concat(user, \"@\", host) = \"%s\"'" % @resource[:name]
		execpipe(cmd) do |process|
			process.each do |line|
				unless result.empty?
					raise Puppet::Error,
          "Got multiple results for user '%s'" % @resource[:name]
				end
				result = query_line_to_hash(line)
			end
		end
		result
	end

	def create
    if @resource[:identified_with]
      if @resource[:password_hash]
        raise Puppet::Error, "Can't provide both identified_with and password_hash for user '%s'" % @resource[:name]
      end
      mysql "mysql", "-e", "create user '%s' identified with %s" % [ @resource[:name].sub("@", "'@'"), @resource.should(:identified_with) ]
    else
      mysql "mysql", "-e", "create user '%s' identified by PASSWORD '%s'" % [ @resource[:name].sub("@", "'@'"), @resource.should(:password_hash) ]
    end
		mysql_flush
	end

	def destroy
		mysql "mysql", "-e", "drop user '%s'" % @resource[:name].sub("@", "'@'")
		mysql_flush
	end

	def exists?
		not mysql("mysql", "-NBe", "select '1' from user where CONCAT(user, '@', host) = '%s'" % @resource[:name]).empty?
	end

	def password_hash
		@property_hash[:password_hash]
	end

	def password_hash=(string)
		mysql "mysql", "-e", "SET PASSWORD FOR '%s' = '%s'" % [ @resource[:name].sub("@", "'@'"), string ]
		mysql_flush
	end

	def identified_with
		@property_hash[:identified_with]
	end

  def identified_with=(string)
    mysql "mysql", "-e", "update mysql.user set plugin='%s' where CONCAT(user, '@', host) = '%s'" % [string, @resource[:name]]
    mysql_flush
  end

end

