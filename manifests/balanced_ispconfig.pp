# = Define haproxy::balanced_ispconfig
#
# This define must be used in balanced hosts.
# It exports a fragment collected by balancers.
# Balancer will put this host in ispconfig admin panel balancement
#
# == Params
#
# [*cluster_balancer*]
#   Cluster name of the balancer. <name> will be used if it's not defined
#
# [*balanced_interface*]
#   Interface that listen to balancer requests
#
# == Example
#
# We suppose this scenario:
#   - foo is the balancer cluster's name
#   - we have a cluster named bar composed by bar01 and bar02 hosts
#   - ispconfig is installed on bar01 host
#
# node clusterfoo {
#   haproxy::generic_tcp_balance {"clusterbar_ispconfig":
#     port            => '81',
#     bind_addresses  => $vip,
#   }
# }
#
# Note: instead of define every balanced service on the balancer, you can use haproxy::cluster_balance define. This define configure balancement of every common services, except http
#
# node clusterbar {
#   $cluster = 'bar'
#
# }
#
# node bar01.domain inherits clusterbar {
#   haproxy::balanced_ispconfig {'foo':
#     balanced_interface  => 'eth0'
#   }
# }
#
# node bar02.domain inherits clusterbar {
#
# }
#
define haproxy::balanced_ispconfig (
  $cluster_balancer = '',
  $balanced_interface,
  $server_check     = true,
  $inter            = '10s',
  $downinter        = '1s',
  $fastinter        = '1s',
  $rise             = 2,
  $fall             = 3,
  $weight           = 100,
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

  @@haproxy::backend::server { "${hostname}-ispconfig" :
    bind          => inline_template("<%= ipaddress_${balanced_interface} %>"),
    tag           => "cluster${cluster}_ispconfig_${balancer_cluster}",
    backup        => $backup,
    weight        => $weight,
    inter         => $inter,
    server_check  => $server_check,
    downinter     => $downinter,
    fastinter     => $fastinter,
    rise          => $rise,
    fall          => $fall,
  }
}
