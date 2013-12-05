# = Define haproxy::balanced
#
# This define must be used in balanced hosts.
# It exports fragments collected by balancers.
# Balancer will put this host in every service's backend servers
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
#   For some services we use A/P balancement. For those services, only hostname specified with this parameter will be considered up. Other hosts will be used as backup
#
# [*http*]
#   Set to true if http service on this host have to be balanced by <cluster_balancer>. Default: true
#
# [*ssh*]
#   Set to true if ssh service on this host have to be balanced by <cluster_balancer>. Default: true
#
# [*nrpe*]
#   Set to true if nrpe service on this host have to be balanced by <cluster_balancer>. Default: true
#
# [*smtp*]
#   Set to true if smtp service on this host have to be balanced by <cluster_balancer>. Default: true
#
# [*pop*]
#   Set to true if pop service on this host have to be balanced by <cluster_balancer>. Default: true
#
# [*imap*]
#   Set to true if imap service on this host have to be balanced by <cluster_balancer>. Default: true
#
# [*ispconfig*]
#   Set to true if ispconfig service on this host have to be balanced by <cluster_balancer>. Default: true
#
# [*http_weight*]
#   weight to assign to http balancement (other service are balanced in A/P mode). Default: 100
#
# == Example
#
# We suppose this scenario:
#   - foo is the balancer cluster's name
#   - we have a cluster named bar composed by bar01 and bar02 hosts
#   - we want to balance every service, excepts for http, on bar cluster through foo balancer. bar01 will be the active node
#
# node clusterfoo {
#   haproxy::cluster_balance {"bar":
#     local_interface  => ethX # local interface on balancer host. Local service on balancer host will bind on this interface, example: ssh, smtp, nrpe
#     vip               => $vip,
#   }
#
# node clusterbar {
#   $cluster = 'bar'
#
#   haproxy::balanced {'foo':
#      balanced_interface  => 'eth0',
#      active_node         => 'bar01',
#      http                => false
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
#
define haproxy::balanced (
  $cluster_balancer = '',
  $balanced_interface,
  $active_node      = '',
  $http             = true,
  $ftp              = true,
  $ssh              = true,
  $nrpe             = true,
  $smtp             = true,
  $pop              = true,
  $imap             = true,
  $ispconfig        = true,
  $http_weight      = '100',
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

  if $http {
    @@haproxy::backend::server { $hostname :
      bind    => inline_template("<%= ipaddress_${balanced_interface} %>"),
      tag     => "cluster${cluster}_http_${balancer_cluster}",
      weight  => $http_weight,
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

  if $ispconfig and ($active_node == $hostname) {
    @@haproxy::backend::server { "${hostname}-ispconfig" :
      bind  => inline_template("<%= ipaddress_${balanced_interface} %>"),
      tag   => "cluster${cluster}_ispconfig_${balancer_cluster}",
      backup  => $backup,
    }
  }
}
