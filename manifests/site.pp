node default {
  class { "basic_server":
  }

  hiera_include('classes')
}
