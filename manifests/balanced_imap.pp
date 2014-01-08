# = Define haproxy::balanced_imap
#
# This define must be used in balanced hosts.
# It exports a fragment collected by balancers.
# Balancer will put this host in imap backend servers
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
#   For imap balacement we use A/P balancement. Only hostname specified with this parameter will be considered up. Other hosts will be used as backup
#
# == Example
#
# We suppose this scenario:
#   - foo is the balancer cluster's name
#   - we have a cluster named bar composed by bar01 and bar02 hosts
#   - we want to balance imap service on bar cluster through foo balancer. bar01 will be the active node
#
# node clusterfoo {
#   haproxy::imap_balance {"clusterbar_ftp":
#     bind_addresses  => <vip address>,
#   }
# }
#
# Note: instead of define every balanced service on the balancer, you can use haproxy::cluster_balance define. This define configure balancement of every common services, except http
#
# node clusterbar {
#   $cluster = 'bar'
#
#   haproxy::balanced_imap {'foo':
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
define haproxy::balanced_imap (
  $cluster_balancer = '',
  $balanced_interface,
  $active_node      = '',
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

  @@haproxy::backend::server { "${hostname}-imap" :
    bind          => inline_template("<%= ipaddress_${balanced_interface} %>"),
    tag           => "cluster${cluster}_imap_${balancer_cluster}",
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