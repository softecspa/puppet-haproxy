class haproxy::datadog {

  if $public_interface == undef {
    fail('To enable datadog monitor you must define $public_interface variabile')
  }

  $ip_datadog=inline_template("<%= ipaddress_${public_interface} %>"),

  file {'/etc/dd-agent/conf.d/haproxy.yaml':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '644',
    content => template('haproxy/datadog.erb'),
    notify  => Service['datadog-agent'],
  }

}
