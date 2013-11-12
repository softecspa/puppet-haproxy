# = Define haproxy::generic_tcp_balance
#
#   This define creates a conjuction of frontend and backend to serve a generic tcp service specifiing ip address and port
#
# == Params
#
# [*bind_addresses*]
#   array of address on which bind
#
# [*port*]
#   port on wich addresses bind
#
# [*be_name*]
#   backend's name. <name> will be used if it's not defined
#
# [*backends*]
#   hash of backends to use. Hash can contain as key, all of params presents in haproxy::backend::server define
#
define haproxy::generic_tcp_balance (
  $bind_addresses,
  $backends,
  $backend_options  = '',
  $frontend_options = '',
  $backend_name     = '',
  $port,
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
    fail('invalid ip_address:port value present in bind_addresses')
  }

  $be_name = $backend_name? {
    ''      => $name,
    default => $backend_name
  }

  haproxy::backend {$be_name :
    options => $backend_options
  }
  create_resources(haproxy::backend::server,$backends, {'backend_name' => $be_name, 'port' => $port})

  haproxy::frontend {"frontend_${be_name}" :
    bind            => $bind_addresses,
    default_backend => $be_name,
    port            => $port,
    options         => $frontend_options,
  }
}
