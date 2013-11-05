define haproxy::generic_tcp_balance (
  $bind_addresses,
  $backends,
  $backend_name   = '',
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

  haproxy::backend {$be_name :}
  create_resources(haproxy::backend::server,$backends, {'backend_name' => $be_name, 'port' => $port})

  haproxy::frontend {"frontend_${be_name}" :
    bind            => $bind_addresses,
    default_backend => $be_name,
    port            => $port
  }
}
