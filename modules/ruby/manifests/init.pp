# Use the brightbox ruby-ng packages (pretty much required for Ubuntu
# versions less than Oneiric
class ruby::ng {
  apt::ppa { "ruby-ng": ppa => "brightbox/ruby-ng" }
}


# Used by the other classes, you don't need to include this
class ruby::common {
  file { "/usr/local/bin/bundle":
    ensure => "/usr/bin/bundle"
  }
  package { "git-core":
    ensure => installed
  }
  package { ["ruby", "ruby-dev", "rake"]:
    ensure => installed
  }
  package { ["bundler"]:
    provider => gem,
    ensure => latest
  }
}

# Some handy dependencies used commonly by Rails apps
class ruby::rails {
  package { ["libxml2-dev", "libxslt1-dev", "libmysqlclient-dev", "libsqlite3-dev", "libonig-dev", "graphicsmagick-imagemagick-compat", "graphicsmagick-libmagick-dev-compat", "libssl-dev"]:
    ensure => installed
  }
}

# setup ruby1.8 packages and install common dependencies and gems,
# including bundler.
#
# If $system_default is true, then ruby1.8 will be the system-wide default
# version of ruby
class ruby::ruby18($system_default = true) {
  include ruby::common
  package { ["ruby1.8", "ruby1.8-dev"]:
    ensure => installed
  }
  Package["ruby1.8"] -> Package["ruby"]
  Package["ruby1.8-dev"] -> Package["ruby-dev"]
  
  package { ["rubygems", "rubygems1.8"]:
    ensure => latest
  }

  Package["rubygems"] -> Package["bundler"]
  Exec["ruby1.8-install-bundler"] -> Package["bundler"]

  exec { "ruby1.8-install-bundler":
    command => "/usr/bin/gem1.8 install -f --no-rdoc --no-ri --format-executable --bindir /usr/local/bin  bundler",
    creates => "/usr/local/bin/bundle1.8",
    require => Package["rubygems"]
  }

  exec { "bundle1.8-alternatives":
    command => "/usr/sbin/update-alternatives --install /usr/bin/bundle bundle /usr/local/bin/bundle1.8 1",
    require => Exec["ruby1.8-install-bundler"]
  }
  
  if $system_default {
    exec { "update-alternatives-ruby1.8":
      path => "/usr/sbin",
      command => "update-alternatives --set ruby /usr/bin/ruby1.8 && update-alternatives --set gem /usr/bin/gem1.8 && update-alternatives --set bundle /usr/local/bin/bundle1.8",
      require => [Package["ruby"], Package["ruby1.8"], Package["rubygems"], Exec["ruby1.8-install-bundler"]]
    }
  }

}

# setup ruby1.9 packages and install common dependencies and gems,
# including bundler.
#
# If $system_default is true, then ruby1.9 will be the system-wide default
# version of ruby

class ruby::ruby19($system_default = true)  {
  include ruby::common
  package { ["ruby1.9.1", "ruby1.9.1-dev"]:
    ensure => installed
  }
  Package["ruby1.9.1"] -> Package["ruby"]
  Package["ruby1.9.1-dev"] -> Package["ruby-dev"]

  Package["ruby1.9.1"] -> Package["bundler"]
  Exec["ruby1.9-install-bundler"] -> Package["bundler"]

  exec { "ruby1.9-install-bundler":
    command => "/usr/bin/gem1.9.1 install -f --no-rdoc --no-ri --format-executable --bindir /usr/local/bin  bundler",
    creates => "/usr/local/bin/bundle1.9.1",
    require => Package["ruby1.9.1"]
  }

  exec { "bundle1.9-alternatives":
    command => "/usr/sbin/update-alternatives --install /usr/bin/bundle bundle /usr/local/bin/bundle1.9.1 2",
    require => Exec["ruby1.9-install-bundler"]
  }
  
  if $system_default {
    exec { "update-alternatives-ruby1.9.1":
      path => "/usr/sbin",
      command => "update-alternatives --set ruby /usr/bin/ruby1.9.1 && update-alternatives --set gem /usr/bin/gem1.9.1 && update-alternatives --set bundle /usr/local/bin/bundle1.9.1",
      require => [Package["ruby"], Package["ruby1.9.1"], Exec["ruby1.9-install-bundler"]]
    }
  }

}
