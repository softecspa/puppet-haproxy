class haproxy::config {

  concat_build { 'haproxy':
    order   => ['*.tmp'],
    target  => "${haproxy::params::config_dir}/haproxy.cfg",
    notify  => $haproxy::params::service_name,
  }

  concat_fragment { 'haproxy+001.tmp':
    content => template('haproxy/haproxy_header.erb')
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
    owner   => $haproxy::haproxy_user_group,
    group   => $haproxy::haproxy_user_group
  }

}
