# = Define haproxy::smtp_balance
#
#   This define uses haproxy::generic_tcp_balance define to balance smtp service.
#   This define bind also local smtp server to the specifed address in local_ip parameter
#
# == Params
#
# [*local_ip*]
#   ip address on which local smtp service have to bind
#
# [*bind_addresses*]
#   array of VIPs on which bind
#
# [*smtp_port*]
#   port on wich VIPs address binds. Default: 25
#
# [*backend_name*]
#   backend's name. <name> will be used if it's not defined
#
# [*backends*]
#   hash of backends to use. Hash can contain as key, all of params presents in haproxy::backend::server define
#
define haproxy::smtp_balance (
  $local_ip,
  $bind_addresses,
  $backends               = '',
  $backend_name           = '',
  $smtp_port              = '25',
  $monitored_hostname     = $::hostname,
  $notifications_enabled  = undef,
  $notification_period    = undef,
) {

  haproxy::generic_tcp_balance { $name :
    bind_addresses        => $bind_addresses,
    backends              => $backends,
    backend_name          => $backend_name,
    port                  => $smtp_port,
    backend_options       => [ 'smtpchk' ],
    monitored_hostname    => $monitored_hostname,
    notifications_enabled => $notifications_enabled,
    notification_period   => $notification_period,
  }

  if !defined(Augeas['smtp_local_bind']) {
    augeas { 'smtp_local_bind':
      context => "/files/etc/postfix/main.cf",
      changes => [
        "set inet_interfaces $local_ip",
      ],
    }
  }
}
