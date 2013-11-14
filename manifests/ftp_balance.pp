# = Define haproxy::ftp_balance
#
#   This define specialize generic_tcp_balance for use in ftp balancement
#
# == Params
#
# [*bind_addresses*]
#   array of VIPs on which bind
#
# [*ftp_port*]
#   port used for ftp service. Default: 21
#
# [*backend_name*]
#   backend's name. <name> will be used if it's not defined
#
# [*backends*]
#   hash of backends to use. Hash can contain as key all of params presents in haproxy::backend::server define
#
# [*passv_ports*]
#   port used for ftp passive mode
#
# == Examples
# 1 - balance ftp service on 192.168.1.100 192.168.1.200 real server balanced on 192.168.0.1 VIP
#
#    haproxy::ftp_balance { 'ftp_foo':
#      bind_addresses  => '192.168.0.1',
#      backends        => { 'backend-01' => {bind => '192.168.1.100'},
#                           'backend-02' => {bind => '192.168.1.200'}, },
#    }
#
# 2 - Same example above, but with backend-02 as backup, and bind on more ip_address
#
#    haproxy::ftp_balance { 'pop3_foo':
#      bind_addresses   => [ '192.168.0.1', '192.168.0.2' ],
#      backends         => { 'backend-01' => {bind => '192.168.1.100'},
#                            'backend-02' => {bind => '192.168.1.200', backup => true}, },
#    }
#
define haproxy::ftp_balance (
  $bind_addresses,
  $backends,
  $backend_name   = '',
  $ftp_port       = '21',
  $passv_ports    = '49100-50000',
) {

  $array_bind_addresses = is_array($bind_addresses)? {
    true  => $bind_addresses,
    false => [ $bind_addresses ],
  }

  if !is_hash($backends) {
    fail('parameter backends must be ah hash')
  }

  $string_binds = inline_template('<% array_bind_addresses.each do |bind| -%><%= bind %> <% end -%>')
  if $string_binds !~ /([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\ )+$/ {
    fail('invalid ip_address value present in bind_addresses')
  }

  $be_name = $backend_name? {
    ''      => $name,
    default => $backend_name
  }

  haproxy::backend {$be_name :}
  create_resources(haproxy::backend::server,$backends, {'backend_name' => $be_name, 'port' => $ftp_port})
  haproxy::frontend {"frontend_${be_name}" :
    bind            => $bind_addresses,
    default_backend => $be_name,
    port            => $ftp_port,
  }

  haproxy::listen {"${be_name}_passv":
    bind    => $bind_addresses,
    monitor => false,
    port    => $passv_ports
  }
  create_resources(haproxy::listen::server,$backends, {'listen_name' => "${be_name}_passv", 'check_port' => $ftp_port})
}
