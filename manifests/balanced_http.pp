define haproxy::balanced_http (
  $cluster_balancer   = '',
  $balanced_interface,
  $weight             = '100',
) {

  if ($cluster == '') or ($cluster == undef) {
    fail ('variable $cluster must be defined')
  }

  $balancer_cluster = $cluster_balancer? {
    ''      => $name,
    default => $cluster_balancer,
  }

  @@haproxy::backend::server { $hostname :
    bind    => inline_template("<%= ipaddress_${balanced_interface} %>"),
    tag     => "cluster${cluster}_http_${balancer_cluster}",
    weight  => $weight,
  }
}
