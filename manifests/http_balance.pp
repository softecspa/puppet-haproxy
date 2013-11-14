# = Define haproxy::generic_http_balance
#
#   This define uses varius haproxy'2 defines to build a balanced http service.
#   By default it adds a request header called X-HaProxy-Id with value $hostname
#
# == Params
#
# [*bind_addresses*]
#   array of VIPs on which bind
#
# [*http_port*]
#   port on wich VIPs address binds. Default: 80
#
# [*backend_name*]
#   backend's name. <name> will be used if it's not defined
#
# [*backends*]
#   hash of backends to use. Hash can contain as key all of params presents in haproxy::backend::server define
#
# [*backend_options*]
#   array of options to pass to backend definition. Default: ['httpclose' , 'forwardfor' ]
#
# [*frontend_option*]
#   array of options to pass to frontend definition. Default: [ 'httplog' ]
#
# [*appsession*]
#   single value or array. Use this application's cookies to mantain persistent sessions.
#
# [*add_request_header*]
#   request headers to add in form of hash. Hash can contain as key all of params present in haproxy::backend::add_header define.
#
# [*cookie_capture*]
#   array of cookie name to capture. When captured, cookie value will be printed in log
#
# [*res_header_capture*]
#   array of response header to capture. When captured, value value will be printed in log
#
# [*req_header_capture*]
#   array of request header to capture. When captured, value value will be printed in log
#
# [*own_logfile*]
#   If true, requests on relied frontend will be logged in a separate file under ${haproxy::log_dir}/frontend_<name>.log
#
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
