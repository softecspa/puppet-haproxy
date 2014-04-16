# = Define haproxy::balanced_ssh
#
# This define must be used in balanced hosts.
# It exports a fragment collected by balancers.
# Balancer will put this host in ssh backend servers
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
#   For ssh balacement we use A/P balancement. Only hostname specified with this parameter will be considered up. Other hosts will be used as backup
#
# == Example
#
# We suppose this scenario:
#   - foo is the balancer cluster's name
#   - we have a cluster named bar composed by bar01 and bar02 hosts
#   - we want to balance ssh service on bar cluster through foo balancer. bar01 will be the active node
#
# node clusterfoo {
#   haproxy::ssh_balance {"clusterbar_smtp":
#     local_ip        => <ip address on which local ssh server on balancer have to bind>,
#     bind_addresses  => $vip,
#   }
#
#
# Note: instead of define every balanced service on the balancer, you can use haproxy::cluster_balance define. This define configure balancement of every common services, except http
#
# node clusterbar {
#   $cluster = 'bar'
#
#   haproxy::balanced_ssh {'foo':
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
define haproxy::balanced_zookeeper (
  $cluster_balancer   = '',
  $balanced_interface = '',
  $balanced_address   = '',
  $active_node        = '',
  $port               = '',
  $balancer_port      = '2180',
) {

  if ($cluster == '') or ($cluster == undef) {
    fail ('variable $cluster must be defined')
  }

  if ($balanced_interface == '') and ($balanced_address == '') {
    fail('please sperify balanced_address or balanced_interface')
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

  $listen_address = $balanced_address? {
    ''      => inline_template("<%= ipaddress_${balanced_interface} %>"),
    default => $balanced_address,
  }

  $hostname_suffix = $balancer_port? {
    '80'    => '',
    default => "-${balancer_port}",
  }

  $port_suffix = $port?{
    ''      => $port,
    default => "-${port}",
  }

  @@haproxy::backend::server { "${hostname}${hostname_suffix}${port_suffix}" :
    server_name => $hostname,
    bind        => $listen_address,
    tag         => "cluster${cluster}_zookeeper_${balancer_cluster}",
    backup      => $backup,
    real_port   => $port
  }
}
