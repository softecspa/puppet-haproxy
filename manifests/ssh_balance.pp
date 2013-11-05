define haproxy::ssh_balance (
  $local_ip,
  $bind_addresses,
  $backends,
  $backend_name   = '',
  $ssh_port       = '22',
) {

  haproxy::generic_tcp_balance { $name :
    bind_addresses  => $bind_addresses,
    backends        => $backends,
    backend_name    => $backend_name,
    port            => $ssh_port,
  }

  if !defined(Augeas['ssh_local_bind']) {
    augeas { 'ssh_local_bind':
      context => "/files/etc/ssh/sshd_config",
      changes => [
        "set ListenAddress $local_ip",
      ],
      notify  => Service['ssh']
    }
  }

}
