define haproxy::smtp_balance (
  $local_ip,
  $bind_addresses,
  $backends,
  $backend_name   = '',
  $smtp_port       = '25',
) {

  haproxy::generic_tcp_balance { $name :
    bind_addresses  => $bind_addresses,
    backends        => $backends,
    backend_name    => $backend_name,
    port            => $smtp_port,
    backend_options => [ 'smtpchk' ],
  }

  if !defined(Augeas['smtp_local_bind']) {
    augeas { 'smtp_local_bind':
      context => "/files/etc/postfix/main.cf",
      changes => [
        "set inet_interfaces $local_ip",
      ],
    }
  }
}
