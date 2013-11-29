class augeas {

  Package["ruby-augeas"] -> Augeas <| |>

  package { "augeas":
    name => 'ruby-augeas',
    ensure => 'installed'
  }

}
