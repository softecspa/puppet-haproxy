# = Define haproxy::cluster_balance
#
#   This define must be used on balancer nodes. It enables balancement of all common service of a cluster, except for http.
#
# == Params
#
# [*clustername*]
#   value of variable $cluster defined in balanced host definition. <name> will be used if it's not specified
#
# [*vip*]
#   vip address on which every service is balanced
#
# [*local_interface*]
#   Interface used to bind local service on balancer host. For example ssh or smtp.
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
#     local_interface => ethX,
#     vip             => $vip,
# }
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
