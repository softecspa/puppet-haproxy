# = Define haproxy::generic_tcp_balance
#
#   This define creates a conjuction of frontend and backend to serve a generic tcp service specifiing ip address and port
#
# == Params
#
# [*bind_addresses*]
#   array of VIPs on which bind (mandatory)
#
# [*port*]
#   port on wich VIPs address binds (mandatory)
#
# [*backend_name*]
#   backend's name. <name> will be used if it's not defined
#
# [*backends*]
#   hash of backends to use. Hash can contain as key, all of params presents 
#   in haproxy::backend::server define
#
# [*backend_options*]
#   array of options to pass to backend definition
#
# [*frontend_options*]
#   array of options to pass to frontend definition
#
# [*monitored_hostname*]
#   Hostname to monitor (defaults to $::hostname)
#
# [*notifications_enabled*]
#   Enable notifications (default: undef)
#
# [*notification_period*]
#   Notification period (default: undef)
#
# == Examples
# 1 - balance pop3 (port 110) service on 192.168.1.100 192.168.1.200 real
#     server balanced on 192.168.0.1 VIP
#
#    haproxy::generic_tcp_balance { 'pop3_foo':
#      bind_addresses  => '192.168.0.1',
#      port            => '110',
#      backends        => { 'backend-01' => {bind => '192.168.1.100'},
#                           'backend-02' => {bind => '192.168.1.200'}, },
#    }
#
# 2 - Same example above, but with backend-02 as backup, option smtpchk in
#     backend and bind on more ip_address
#
#    haproxy::generic_tcp_balance { 'pop3_foo':
#      bind_addresses   => [ '192.168.0.1', '192.168.0.2' ],
#      port             => '110',
#      backends         => { 'backend-01' => {bind => '192.168.1.100'},
#                           'backend-02' => {bind => '192.168.1.200', 
#                                            backup => true}, },
#      backend_options => ['smtpchk']
#    }
#
define haproxy::generic_tcp_balance (
  $bind_addresses,
  $port,
  $backend_name           = '',
  $backends               = '',
  $backend_options        = '',
  $frontend_options       = '',
  $monitored_hostname     = $::hostname,
  $notifications_enabled  = undef,
  $notification_period    = undef,
) {

  $array_bind_addresses = is_array($bind_addresses)? {
    true  => $bind_addresses,
    false => [ $bind_addresses ],
  }

  if (!is_hash($backends)) and ($backends != '') {
    fail('parameter backends must be ah hash')
  }

  $string_binds = inline_template('<% array_bind_addresses.each do |bind| -%><%= bind %> <% end -%>')
  if $string_binds !~ /([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\ )+$/ {
    fail('invalid ip_address:port value present in bind_addresses')
  }

  $be_name = $backend_name? {
    ''      => $name,
    default => $backend_name
  }

  haproxy::backend {$be_name :
    options               => $backend_options,
    monitored_hostname    => $monitored_hostname,
    notifications_enabled => $notifications_enabled,
    notification_period   => $notification_period,
  }
  if is_hash($backends) {
    create_resources(haproxy::backend::server,$backends, {'backend_name' => $be_name, 'port' => $port})
  }
  Haproxy::Backend::Server <<| tag == "${name}_${cluster}" |>> {
    backend_name  => $be_name,
    port          => $port,
  }

  haproxy::frontend {"frontend_${be_name}" :
    bind                  => $bind_addresses,
    default_backend       => $be_name,
    port                  => $port,
    options               => $frontend_options,
    monitored_hostname    => $monitored_hostname,
    notifications_enabled => $notifications_enabled,
    notification_period   => $notification_period,
  }
}
