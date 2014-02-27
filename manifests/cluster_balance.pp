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
  $clustername            = '',
  $vip,
  $local_interface,
  $monitor                = true,
  $monitored_hostname     = $::hostname,
  $notifications_enabled  = undef,
  $notification_period    = undef,
  $ssh_timeout_client     = '',
  $ssh_timeout_server     = '',
  $ssh_timeout_connect    = '',
  $ftp_timeout_client     = '',
  $ftp_timeout_server     = '',
  $ftp_timeout_connect    = '',
  $smtp_timeout_client    = '',
  $smtp_timeout_server    = '',
  $smtp_timeout_connect   = '',
  $pop_timeout_client     = '',
  $pop_timeout_server     = '',
  $pop_timeout_connect    = '',
  $pops_timeout_client    = '',
  $pops_timeout_server    = '',
  $pops_timeout_connect   = '',
  $imap_timeout_client    = '',
  $imap_timeout_server    = '',
  $imap_timeout_connect   = '',
  $imaps_timeout_client   = '',
  $imaps_timeout_server   = '',
  $imaps_timeout_connect  = '',
  $nrpe_timeout_client    = '',
  $nrpe_timeout_server    = '',
  $nrpe_timeout_connect   = '',
  $isp_timeout_client     = '',
  $isp_timeout_server     = '',
  $isp_timeout_connect    = '',
) {

  $cluster_name = $clustername? {
    ''      => $name,
    default => $clustername,
  }

  # SSH
  haproxy::ssh_balance {"cluster${cluster_name}_ssh":
    local_ip              => inline_template("<%= ipaddress_${local_interface} %>"),
    bind_addresses        => $vip,
    monitor               => $monitor,
    monitored_hostname    => $monitored_hostname,
    notifications_enabled => $notifications_enabled,
    notification_period   => $notification_period,
    timeout_client        => $ssh_timeout_client,
    timeout_server        => $ssh_timeout_server,
    timeout_connect       => $ssh_timeout_connect,
  }

  # FTP
  haproxy::ftp_balance {"cluster${cluster_name}_ftp":
    bind_addresses        => $vip,
    monitor               => $monitor,
    monitored_hostname    => $monitored_hostname,
    notifications_enabled => $notifications_enabled,
    notification_period   => $notification_period,
    timeout_client        => $ftp_timeout_client,
    timeout_server        => $ftp_timeout_server,
    timeout_connect       => $ftp_timeout_connect,
  }

  # SMTP
  haproxy::smtp_balance {"cluster${cluster_name}_smtp":
    local_ip              => '127.0.0.1',
    bind_addresses        => $vip,
    monitor               => $monitor,
    monitored_hostname    => $monitored_hostname,
    notifications_enabled => $notifications_enabled,
    notification_period   => $notification_period,
    timeout_client        => $smtp_timeout_client,
    timeout_server        => $smtp_timeout_server,
    timeout_connect       => $smtp_timeout_connect,
  }

  # POP
  haproxy::generic_tcp_balance {"cluster${cluster_name}_pop":
    port                  => '110',
    bind_addresses        => $vip,
    monitor               => $monitor,
    monitored_hostname    => $monitored_hostname,
    notifications_enabled => $notifications_enabled,
    notification_period   => $notification_period,
    timeout_client        => $pop_timeout_client,
    timeout_server        => $pop_timeout_server,
    timeout_connect       => $pop_timeout_connect,
  }

  # POPS
  haproxy::generic_tcp_balance {"cluster${cluster_name}_pops":
    port                  => '995',
    bind_addresses        => $vip,
    monitor               => $monitor,
    monitored_hostname    => $monitored_hostname,
    notifications_enabled => $notifications_enabled,
    notification_period   => $notification_period,
    timeout_client        => $pops_timeout_client,
    timeout_server        => $pops_timeout_server,
    timeout_connect       => $pops_timeout_connect,
  }

  # IMAP
  haproxy::generic_tcp_balance {"cluster${cluster_name}_imap":
    port                  => '143',
    bind_addresses        => $vip,
    monitor               => $monitor,
    monitored_hostname    => $monitored_hostname,
    notifications_enabled => $notifications_enabled,
    notification_period   => $notification_period,
    timeout_client        => $imap_timeout_client,
    timeout_server        => $imap_timeout_server,
    timeout_connect       => $imap_timeout_connect,
  }

  # IMAPS
  haproxy::generic_tcp_balance {"cluster${cluster_name}_imaps":
    port                  => '993',
    bind_addresses        => $vip,
    monitor               => $monitor,
    monitored_hostname    => $monitored_hostname,
    notifications_enabled => $notifications_enabled,
    notification_period   => $notification_period,
    timeout_client        => $imaps_timeout_client,
    timeout_server        => $imaps_timeout_server,
    timeout_connect       => $imaps_timeout_connect,
  }

  # NRPE
  haproxy::nrpe_balance {"cluster${cluster_name}_nrpe":
    local_ip              => inline_template("<%= ipaddress_${local_interface} %>"),
    bind_addresses        => $vip,
    monitor               => $monitor,
    monitored_hostname    => $monitored_hostname,
    notifications_enabled => $notifications_enabled,
    notification_period   => $notification_period,
    timeout_client        => $nrpe_timeout_client,
    timeout_server        => $nrpe_timeout_server,
    timeout_connect       => $nrpe_timeout_connect,
  }

  # ISPCONFIG PANEL
  haproxy::generic_tcp_balance {"cluster${cluster_name}_ispconfig":
    port                  => '81',
    bind_addresses        => $vip,
    monitor               => $monitor,
    monitored_hostname    => $monitored_hostname,
    notifications_enabled => $notifications_enabled,
    notification_period   => $notification_period,
    timeout_client        => $nrpe_timeout_client,
    timeout_server        => $nrpe_timeout_server,
    timeout_connect       => $nrpe_timeout_connect,
  }

}
