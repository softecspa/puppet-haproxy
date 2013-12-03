define haproxy::balanced_ftp (
  $cluster_balancer = '',
  $balanced_interface,
  $active_node      = '',
) {

  if ($cluster == '') or ($cluster == undef) {
    fail ('variable $cluster must be defined')
  }

  $balancer_cluster = $cluster_balancer? {
    ''      => $name,
    default => $cluster_balancer,
  }

  $backup = $active_node?{
    ''        => false,
    $hostname => false,
    default   => true,
  }

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
