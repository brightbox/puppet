module Puppet::Parser::Functions
  newfunction(:ppa_filename, :type => :rvalue) do |args|
    # ppa:brightbox/passenger becomes brightbox-passenger-lucid.list
    filename = args.first.to_s
    raise Puppet::ParseError, "ppa_filename cannot be blank" if filename.empty?
    filename.gsub!(/ppa\:/,'')
    filename.gsub!('/', '-')
    filename.gsub!('.', '_')
    filename += "-#{lookupvar('lsbdistcodename')}"
    filename += ".list"
    "/etc/apt/sources.list.d/" + filename
  end
end
