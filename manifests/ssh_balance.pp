# = Define haproxy::ssh_balance
#
#   This define uses haproxy::generic_tcp_balance define to balance ssh service.
#   This define bind also local sshd server to the specifed address in local_ip parameter
#
# == Params
#
# [*local_ip*]
#   ip address on which local ssh service have to bind
#
# [*bind_addresses*]
#   array of VIPs on which bind
#
# [*ssh_port*]
#   port on wich VIPs address binds. Default: 22
#
# [*backend_name*]
#   backend's name. <name> will be used if it's not defined
#
# [*backends*]
#   hash of backends to use. Hash can contain as key, all of params presents in haproxy::backend::server define
#
define haproxy::ssh_balance (
  $local_ip,
  $bind_addresses,
  $backends               = '',
  $backend_name           = '',
  $ssh_port               = '22',
  $balancer_port          = '22',
  $monitor                = true,
  $monitored_hostname     = $::hostname,
  $notifications_enabled  = undef,
  $notification_period    = undef,
  $timeout_connect        = '',
  $timeout_client         = '',
  $timeout_server         = '',
) {

  haproxy::generic_tcp_balance { $name :
    bind_addresses        => $bind_addresses,
    backends              => $backends,
    backend_name          => $backend_name,
    port                  => $ssh_port,
    balancer_port         => $balancer_port,
    monitor               => $monitor,
    monitored_hostname    => $monitored_hostname,
    notifications_enabled => $notifications_enabled,
    notification_period   => $notification_period,
    timeout_connect       => $timeout_connect,
    timeout_client        => $timeout_client,
    timeout_server        => $timeout_server,
  }

}
