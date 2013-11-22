define haproxy::balanced (
  $cluster_balancer = '',
  $balanced_interface,
  $active_node,
  $http             = true,
  $ftp              = true,
  $ssh              = true,
  $nrpe             = true,
  $smtp             = true,
  $pop              = true,
  $imap             = true,
) {

  if ($cluster == '') or ($cluster == undef) {
    fail ('variable $cluster must be defined')
  }

  $balancer_cluster = $cluster_balancer? {
    ''      => $name,
    default => $cluster_balancer,
  }

  $backup = $active_node?{
    $hostname => false,
    default   => true,
  }

  if $http {
    @@haproxy::backend::server { $hostname :
      bind  => inline_template("<%= ipaddress_${balanced_interface} %>"),
      tag   => "cluster${cluster}_http_${balancer_cluster}",
    }
  }

  if $ftp {
    @@haproxy::backend::server { "${hostname}-ftp" :
      bind    => inline_template("<%= ipaddress_${balanced_interface} %>"),
      tag     => "cluster${cluster}_ftp_${balancer_cluster}",
      backup  => $backup,
    }

    @@haproxy::listen::server { "${hostname}-ftp" :
      bind  => inline_template("<%= ipaddress_${balanced_interface} %>"),
      tag   => "cluster${cluster}_ftp_${balancer_cluster}",
      backup  => $backup,
    }
  }

  if $ssh {
    @@haproxy::backend::server { "${hostname}-ssh" :
      bind  => inline_template("<%= ipaddress_${balanced_interface} %>"),
      tag   => "cluster${cluster}_ssh_${balancer_cluster}",
      backup  => $backup,
    }
  }

  if $nrpe {
    @@haproxy::backend::server { "${hostname}-nrpe" :
      bind  => inline_template("<%= ipaddress_${balanced_interface} %>"),
      tag   => "cluster${cluster}_nrpe_${balancer_cluster}",
      backup  => $backup,
    }
  }

  if $smtp {
    @@haproxy::backend::server { "${hostname}-smtp" :
      bind  => inline_template("<%= ipaddress_${balanced_interface} %>"),
      tag   => "cluster${cluster}_smtp_${balancer_cluster}",
      backup  => $backup,
    }
  }

  if $pop {
    @@haproxy::backend::server { "${hostname}-pop" :
      bind  => inline_template("<%= ipaddress_${balanced_interface} %>"),
      tag   => "cluster${cluster}_pop_${balancer_cluster}",
      backup  => $backup,
    }
  }

  if $imap {
    @@haproxy::backend::server { "${hostname}-imap" :
      bind  => inline_template("<%= ipaddress_${balanced_interface} %>"),
      tag   => "cluster${cluster}_imap_${balancer_cluster}",
      backup  => $backup,
    }
  }
}
