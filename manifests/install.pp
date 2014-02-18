class haproxy::install {

  package {$haproxy::params::package_name :
    ensure  => present,
  }

  if ($haproxy::enable_hatop) {
    package {$haproxy::params::hatop_package_name :
      ensure  => present,
    }

    if !defined(Package[$haproxy::params::socat_package_name]) {
      package {$haproxy::params::socat_package_name : 
        ensure  => present,
      }
    }
  }

}
