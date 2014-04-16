# = Define haproxy::balanced_http
#
# This define must be used in balanced hosts.
# It exports a fragment collected by balancers.
# Balancer will put this host in http backend servers
#
# == Params
#
# [*cluster_balancer*]
#   Cluster name of the balancer. <name> will be used if it's not defined
#
# [*balanced_interface*]
#   Interface that listen to balancer requests
#
# [*weight*]
#   Weight to assign on specified host in the balancer config. Default: 100
#
# == Example
#
# We suppose this scenario:
#   - foo is the balancer cluster's name
#   - we have a cluster named bar composed by bar01 and bar02 hosts
#   - we want to balance http service on bar cluster through foo balancer. bar01 and bar02 will have same weight
#
# node clusterfoo {
#   haproxy::http_balance {"clusterbar_http":
#     bind_addresses  => <vip address>,
#   }
# }
#
# node clusterbar {
#   $cluster = 'bar'
#
#   haproxy::balanced_http {'foo':
#      balanced_interface  => 'eth0',
#    }
# }
#
# node bar01.domain inherits clusterbar {
#
# }
#
# node bar02.domain inherits clusterbar {
#
# }
#
define haproxy::balanced_http (
  $cluster_balancer   = '',
  $balanced_interface = '',
  $balanced_address   = '',
  $weight             = '100',
  $inter              = '3s',
  $server_check       = true,
  $downinter          = '1s',
  $fastinter          = '1s',
  $rise               = 2,
  $fall               = 3,
  $backup             = false,
  $balancer_port      = '80',
  $port               = ''
) {

  if ($cluster == '') or ($cluster == undef) {
    fail ('variable $cluster must be defined')
  }

  if ($balancer_port == '') or (!is_integer($balancer_port)) {
    fail('balancer_port parameter must be a valid integer')
  }

  if ($balanced_interface == '') and ($balanced_address == '') {
    fail('please sperify balanced_address or balanced_interface')
  }

  $balancer_cluster = $cluster_balancer? {
    ''      => $name,
    default => $cluster_balancer,
  }

  $tag= $balancer_port? {
    '80'    => "cluster${cluster}_http_${balancer_cluster}",
    default => "cluster${cluster}${balancer_port}_http_${balancer_cluster}"
  }

  $hostname_suffix = $balancer_port? {
    '80'    => '',
    default => "-${balancer_port}",
  }

  $port_suffix = $port?{
    ''      => $port,
    default => "-${port}",
  }

  $listen_address = $balanced_address? {
    ''      => inline_template("<%= ipaddress_${balanced_interface} %>"),
    default => $balanced_address,
  }

  @@haproxy::backend::server { "${hostname}${hostname_suffix}${port_suffix}":
    bind          => $listen_address,
    server_name   => $hostname,
    tag           => $tag,
    weight        => $weight,
    inter         => $inter,
    server_check  => $server_check,
    downinter     => $downinter,
    fastinter     => $fastinter,
    rise          => $rise,
    fall          => $fall,
    backup        => $backup,
    real_port     => $port,
  }
}
