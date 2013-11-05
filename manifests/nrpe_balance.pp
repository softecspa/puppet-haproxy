define haproxy::nrpe_balance (
  $local_ip,
  $bind_addresses,
  $backends,
  $backend_name   = '',
  $nrpe_port      = '5666',
) {


  haproxy::generic_tcp_balance { $name :
    bind_addresses  => $bind_addresses,
    backends        => $backends,
    backend_name    => $backend_name,
    port            => $nrpe_port,
  }

  if !defined(File["${nrpe::nagiosconfdir}/local_bind.cfg"]) {
    file {"${nrpe::nagiosconfdir}/local_bind.cfg":
      ensure  => present,
      content => "server_address=${local_ip}",
      mode    => '644',
      owner   => 'root',
      group   => 'root',
      notify  => Service['nagios-nrpe-server'],
      before  => Service[$haproxy::params::service_name]
    }
  }


}
