module Puppet::Parser::Functions
  newfunction(:apt_repository_name, :type => :rvalue) do |args|
    # ppa:brightbox/passenger becomes brightbox-passenger-lucid.list
    # cloud-archive:havana becomes cloudarchive-havana.list
    filename = args.first.to_s
    raise Puppet::ParseError, "apt_repository_name cannot be blank" if filename.empty?
    n, l = filename.split(':', 2)
    filename = n.gsub('-', '') + '-' + l
    filename.gsub!('/', '-')
    filename.gsub!('.', '_')
    if n == 'ppa'
      filename.gsub!('ppa-','')
      filename += "-#{lookupvar('lsbdistcodename')}"
    end
    filename
  end
end
