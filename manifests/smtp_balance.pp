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


  # faccio generare file di log distinti per gestirli in maniera distinta con la rotazione dei log.
  # Altrimenti avrei più risorse logrotate con lo stesso nome o più rotazioni che insistono sullo stesso file.
  @@haproxy::rsyslog_facility  {"${name}-${hostname}":
    addresses       => $ipaddresses,
    description     => "postfix_check_${hostname}",
    logdir          => '/var/log/haproxy_checks',
    log_file        => "${hostname}-mail.log",
    file_template   => 'haproxy/rsyslog_facility_mail.erb',
    logrotate       => true,
    rotate          => 'daily',
    retention_days  => '2',
    create          => '640 syslog adm',
    tag             => "rsyslog_facility_haproxy_checks-${cluster}",
  }
}
