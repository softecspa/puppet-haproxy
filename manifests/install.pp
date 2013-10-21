class haproxy::install {

  package {$haproxy::params::package_name :
    ensure  => present,
  }

  if ($haproxy::enable_hatop) {
    package {$haproxy::params::hatop_package_name :
      ensure  => present,
    }
  }

}
