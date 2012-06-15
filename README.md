# The Brightbox Puppet Modules

Find enclosed a collection of puppet modules developed by the
[Brightbox](http://brightbox.com) devops team. They're extracted from
modules that have been used in production for years to manage large
and diverse Ubuntu-based web clusters (first on our
[ruby platform](http://www.brightbox.co.uk) and then more recently on
our [cloud platform](http://brightbox.com).

## Background

Up until now they've only been used internally at Brightbox, so may
lack some documentation but work will be done to improve that.

They're developed mostly against Ubuntu Lucid, but we're adding
support for Ubuntu Precise.

Work to extract the modules in a useful is ongoing, so more and more
will be appearing.

They're not meant to be totally general purpose feature-complete
modules - we use them mostly to manage web clusters for ourselves and
for our customers. So they can be quite opinionated - they may not
play nicely with modules from 3rd parties and in some cases completely
replace distro-supplied config files with our own best practises.

## Help

If you need any help getting going with these, feel free to post on
our forum at http://forum.brightbox.com/

You can file tickets reporting bugs or feature ideas at the github
issue tracker at https://github.com/brightbox/puppet/issues

If you want professional support from us, drop us a line at
`hello@brightbox.com`.

## Code

The code is available on Github at https://github.com/brightbox/puppet
and is release under the terms of version 3 of the GNU Public
License. See the file LICENSE for the full text of the license.

## Puppet forge

We're also making the modules available separately for convenient
installation via Puppetlabs Puppet Forge, at
http://forge.puppetlabs.com/users/brightbox

