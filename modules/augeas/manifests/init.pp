class augeas {

  Package["augeas"] -> Augeas <| |>

  if $operatingsystemrelease >= 13 {
    $package_name = 'ruby-augeas'
  } else {
    $package_name = 'libaugeas-ruby'
  }

  package { "augeas":
    name => $package_name,
    ensure => 'installed'
  }

}
