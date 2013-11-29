class ssh_activate {
  
  user { 'ssh_user':
    name => 'ssh',
    ensure => 'present',
    comment => 'SSH activation facility',
    gid => 'ubuntu',
    home => '/home/ssh',
    password => '',
    managehome => false
  }

  file { 'ssh_sudoers':
    path 	=> '/etc/sudoers.d/90-ssh-activate',
    owner	=> 'root', 
    group	=> 'root',
    mode	=> '0440',
    content	=> template('ssh_activate/90-ssh-activate')
  }

  file { 'ssh_hushlogin':
    path	=> '/home/ssh/.hushlogin',
    ensure	=> present,
    owner	=> 'ssh',
    group 	=> 'ubuntu',
    mode	=> '0644',
    require	=> File['ssh_home_dir']
  }

  file { 'ssh_profile':
    path	=> '/home/ssh/.profile',
    content	=> template('ssh_activate/profile'),
    ensure	=> present,
    owner	=> 'ssh',
    group 	=> 'ubuntu',
    mode	=> '0644',
    require	=> File['ssh_home_dir']
  }

  file { 'ssh_bin_dir':
    path	=> '/home/ssh/bin',
    ensure	=> directory,
    owner	=> 'ssh',
    group 	=> 'ubuntu',
    mode	=> '0755',
    require	=> File['ssh_home_dir']
  }

  file { 'ssh_home_dir':
    path	=> '/home/ssh',
    ensure	=> directory,
    owner	=> 'ssh',
    group 	=> 'ubuntu',
    mode	=> '0755',
    require	=> User['ssh_user']
  }

  file { 'time_activate':
    path	=> '/home/ssh/bin/time_activate_ssh',
    content	=> template('ssh_activate/time_activate_ssh'),
    owner	=> 'ssh',
    group 	=> 'ubuntu',
    mode	=> '0755',
    require	=> File['ssh_bin_dir']
  }

  file { 'turn_off_ssh':
    path	=> '/etc/ssh/sshd_not_to_be_run',
    ensure	=> present,
    owner	=> 'root',
    group	=> 'root',
    mode	=> '0644'
  }

  service { 'deactivate_sshd':
    name => 'ssh',
    ensure => 'stopped'
  }

  augeas { "sshd_config":
    context => "/files/etc/ssh/sshd_config",
    changes => [
      "set PermitRootLogin no",
      "set PasswordAuthentication no"
    ],
  }

  Package["ruby-augeas"] -> Augeas <| |>
  
}
