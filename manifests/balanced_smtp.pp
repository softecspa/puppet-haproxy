# = Define haproxy::balanced_smtp
#
# This define must be used in balanced hosts.
# It exports a fragment collected by balancers.
# Balancer will put this host in smtp backend servers
#
# == Params
#
# [*cluster_balancer*]
#   Cluster name of the balancer. <name> will be used if it's not defined
#
# [*balanced_interface*]
#   Interface that listen to balancer requests
#
# [*active_node*]
#   For smtp balacement we use A/P balancement. Only hostname specified with this parameter will be considered up. Other hosts will be used as backup
#
# == Example
#
# We suppose this scenario:
#   - foo is the balancer cluster's name
#   - we have a cluster named bar composed by bar01 and bar02 hosts
#   - we want to balance smtp service on bar cluster through foo balancer. bar01 will be the active node
#
# node clusterfoo {
#   haproxy::smtp_balance {"clusterbar_smtp":
#     local_ip        => <ip address on which local smtp server on balancer have to bind>,
#     bind_addresses  => $vip,
#   }
#
#
# Note: instead of define every balanced service on the balancer, you can use haproxy::cluster_balance define. This define configure balancement of every common services, except http
#
# node clusterbar {
#   $cluster = 'bar'
#
#   haproxy::balanced_smtp {'foo':
#      balanced_interface  => 'eth0',
#      active_node         => 'bar01',
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
define haproxy::balanced_smtp (
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

  @@haproxy::backend::server { "${hostname}-smtp" :
    bind        => inline_template("<%= ipaddress_${balanced_interface} %>"),
    server_name => $hostname,
    tag         => "cluster${cluster}_smtp_${balancer_cluster}",
    backup      => $backup,
  }
}
