define haproxy::http_balance (
  $backends,
  $backend_name       = '',
  $bind_addresses,
  $appsession         = '',
  $add_request_header = '',
  $backend_options    = [ 'httpclose' , 'forwardfor' ],
  $frontend_options   = [ 'httplog' ],
  $cookie_capture     = '',
  $res_header_capture = '',
  $req_header_capture = '',
  $http_port          = '80',
  $own_logfile        = false,
) {

  if !is_hash($backends) {
    fail('backends parameter must be hash')
  }

  $array_bind_addresses = is_array($bind_addresses)? {
    true  => $bind_addresses,
    false => [ $bind_addresses ],
  }

  $array_appsession = is_array($appsession)? {
    true  => $appsession,
    false => [ $appsession ],
  }

  if (!is_hash($add_request_header)) and ($add_request_header != ''){
    fail('parameter add_request_header must be an hash')
  }

  $array_be_options = is_array($backend_options)? {
    true  => $backend_options,
    false => [ $backend_options ],
  }

  $array_fe_options = is_array($frontend_options)? {
    true  => $frontend_options,
    false => [ $frontend_options ],
  }

  $array_cookie_capture = is_array($cookie_capture)? {
    true  => $cookie_capture,
    false => [ $cookie_capture ],
  }

  $array_res_header_capture = is_array($res_header_capture)? {
    true  => $res_header_capture,
    false => [ $res_header_capture ],
  }

  $array_req_header_capture = is_array($req_header_capture)? {
    true  => $req_header_capture,
    false => [ $req_header_capture ],
  }

  $string_binds = inline_template('<% array_bind_addresses.each do |bind| -%><%= bind %> <% end -%>')
  if $string_binds !~ /([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\ )+$/ {
    fail('invalid ip_address:port value present in bind_addresses')
  }

  $be_name = $backend_name ? {
    ''      => $name,
    default => $backend_name,
  }

  haproxy::backend {$be_name:
    options => $array_be_options,
    mode    => 'http'
  }

  create_resources(haproxy::backend::server, $backends, {'backend_name' => $be_name, 'port' => $http_port})
  if $add_request_header != '' {
    create_resources(haproxy::backend::add_header, $add_request_header, {'backend_name' => $be_name, 'type' => 'req'})
  }

  haproxy::frontend {"frontend_${be_name}":
    bind            => $bind_addresses,
    port            => $http_port,
    default_backend => $be_name,
    options         => $array_fe_options,
    mode            => 'http',
    own_logfile     => $own_logfile,
  }

  haproxy::backend::add_header { 'X-HaProxy-Id':
    backend_name  => $be_name,
    type          => 'req',
    value         => $hostname,
  }

  if $appsession != '' {
    haproxy::backend::appsession {$array_appsession :
      backend_name  => $be_name,
      options       => ['request-learn' , 'prefix'],
    }
  }

  if $cookie_capture != '' {
    haproxy::frontend::capture {$array_cookie_capture :
      frontend_name => "frontend_${be_name}",
      capture_type  => 'cookie',
      length        => 52,
    }
  }

  if $res_header_capture != '' {
    haproxy::frontend::capture {$array_res_header_capture :
      frontend_name => "frontend_${be_name}",
      capture_type  => 'response header',
      length        => 10,
    }
  }

  if $req_header_capture != '' {
    haproxy::frontend::capture {$array_req_header_capture :
      frontend_name => "frontend_${be_name}",
      capture_type  => 'request header',
      length        => 10,
    }
  }
}
