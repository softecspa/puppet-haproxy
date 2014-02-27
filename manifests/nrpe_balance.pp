# = Define haproxy::nrpe_balance
#
#   This define uses haproxy::generic_tcp_balance define to balance nrpe service.
#   This define bind also local nrpe server to the specifed address in local_ip parameter
#
# == Params
#
# [*local_ip*]
#   ip address on which local nrpe service have to bind
#
# [*bind_addresses*]
#   array of VIPs on which bind
#
# [*nrpe_port*]
#   port on wich VIPs address binds. Default: 5666
#
# [*backend_name*]
#   backend's name. <name> will be used if it's not defined
#
# [*backends*]
#   hash of backends to use. Hash can contain as key, all of params presents in haproxy::backend::server define
#
define haproxy::nrpe_balance (
  $local_ip,
  $bind_addresses,
  $backends               = '',
  $backend_name           = '',
  $nrpe_port              = '5666',
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
    port                  => $nrpe_port,
    monitor               => $monitor,
    monitored_hostname    => $monitored_hostname,
    notifications_enabled => $notifications_enabled,
    notification_period   => $notification_period,
    timeout_connect       => $timeout_connect,
    timeout_client        => $timeout_client,
    timeout_server        => $timeout_server,
  }

  if !defined(File["${nrpe::nagiosconfdir}/local_bind.cfg"]) {
    file {"${nrpe::nagiosconfdir}/local_bind.cfg":
      ensure  => present,
      content => "server_address=${local_ip}",
      mode    => '644',
      owner   => 'root',
      group   => 'root',
      notify  => Service['nagios-nrpe-server'],
      before  => Service[$haproxy::params::service_name]
    }
  }


}
