class haproxy::config {

  if $haproxy::log_dir != false {
    file {$haproxy::log_dir :
      ensure  => directory,
      mode    => 664,
      owner   => 'syslog',
      group   => 'adm',
    }
  }

  file {"${haproxy::params::config_dir}/haproxy.cfg":
    ensure  => present,
    mode    => 664,
    owner   => 'root',
    group   => 'root',
    require => Concat_build['haproxy']
  }

  concat_build { 'haproxy':
    order   => ['*.tmp'],
    target  => "${haproxy::params::config_dir}/haproxy.cfg",
  }

  concat_fragment { 'haproxy+001.tmp':
    content => template('haproxy/haproxy_header.erb'),
  }

  $enabled = $haproxy::service_ensure? {
    true    => 1,
    running => 1,
    default => 0
  }

  augeas { 'enable-haproxy':
    context => "/files${haproxy::params::default_config}",
    changes => [
      "set ENABLED $enabled",
    ]
  }

  file { '/var/run/haproxy':
    ensure  => directory,
    mode    => '0755',
    owner   => $haproxy::user,
    group   => $haproxy::group
  }

}
