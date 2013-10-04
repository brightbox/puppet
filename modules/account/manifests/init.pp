#
# creates a user and group with $name and $uid, sets up
# authorized_keys if provided.

# provide an array of strings to $authorized_keys or leave as false to
# leave the file untouched
#
define account($uid,
               $home = "/home/$name",
               $shell = '/bin/bash',
               $managehome = false,
               $system = false,
               $groups = false,
               $authorized_keys = false
) {
  group { $name:
    ensure => present,
    gid => $uid
  }
  user { $name:
    ensure     => present,
    uid        => $uid,
    gid        => $uid,
    home       => $home,
    shell      => $shell,
    managehome => $managehome,
    system     => $system,
    require    => Group[$name]
  }

  if $groups {
    User[$name] {
      groups +> $groups,
    }
  }
  
  file { $home:
    ensure => directory,
    owner => $name, group => $name,
    mode => 751,
    require => User[$name]
  }

  # For upstart init configs
  file { "$home/.init":
    ensure => directory,
    owner => $name, group => $name,
    require => File[$home]
  }

  file { "$home/.ssh":
    ensure => directory,
    owner => $name, group => $name,
    mode => 700,
    require => File[$home],
  }
  
  if $authorized_keys {
    file { "$home/.ssh/authorized_keys":
      content => inline_template("# Managed by puppet\n<%= authorized_keys.join(\"\n\") %>"),
      owner => $name, group => $name,
      mode => 600,
      require => File["$home/.ssh"]
    }
  }

}
