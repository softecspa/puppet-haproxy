define haproxy::cluster_balance (
  $clustername      = '',
  $vip,
  $local_interface,
) {

  $cluster_name = $clustername? {
    ''      => $name,
    default => $clustername,
  }

  # SSH
  haproxy::ssh_balance {"cluster${cluster_name}_ssh":
    local_ip        => inline_template("<%= ipaddress_${local_interface} %>"),
    bind_addresses  => $vip,
  }

  # FTP
  haproxy::ftp_balance {"cluster${cluster_name}_ftp":
    bind_addresses  => $vip,
  }

  # SMTP
  haproxy::smtp_balance {"cluster${cluster_name}_smtp":
    local_ip        => '127.0.0.1',
    bind_addresses  => $vip,
  }

  # POP
  haproxy::generic_tcp_balance {"cluster${cluster_name}_pop":
    port            => '110',
    bind_addresses  => $vip,
  }

  # IMAP
  haproxy::generic_tcp_balance {"cluster${cluster_name}_imap":
    port            => '143',
    bind_addresses  => $vip,
  }

  # NRPE
  haproxy::nrpe_balance {"cluster${cluster_name}_nrpe":
    local_ip        => inline_template("<%= ipaddress_${local_interface} %>"),
    bind_addresses  => $vip,
  }

  # ISPCONFIG PANEL
  haproxy::generic_tcp_balance {"cluster${cluster_name}_ispconfig":
    port            => '81',
    bind_addresses  => $vip,
  }

}
