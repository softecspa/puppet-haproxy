# = Define haproxy::generic_http_balance
#
#   This define uses varius haproxy defines to build a balanced http service.
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
# [*monitored_hostname*]
#   hostname to use in nagios_check. Default: $hostname
#
define haproxy::http_balance (
  $backends               = '',
  $backend_name           = '',
  $bind_addresses,
  $appsession             = '',
  $add_request_header     = '',
  $backend_options        = [ 'httpclose' , 'forwardfor' ],
  $frontend_options       = [ 'httplog' ],
  $cookie_capture         = '',
  $res_header_capture     = '',
  $req_header_capture     = '',
  $http_port              = '80',
  $own_logfile            = false,
  $monitor                = true,
  $monitored_hostname     = $::hostname,
  $notifications_enabled  = undef,
  $notification_period    = undef,
  $timeout_connect        = '',
  $timeout_client         = '',
  $timeout_server         = '300000',
) {

  if (!is_hash($backends)) and ($backends != '') {
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
    options               => $array_be_options,
    mode                  => 'http',
    monitor               => $monitor,
    monitored_hostname    => $monitored_hostname,
    notifications_enabled => $notifications_enabled,
    notification_period   => $notification_period,
    timeout_connect       => $timeout_connect,
    timeout_server        => $timeout_server,
  }

  if is_hash($backends) {
    create_resources(haproxy::backend::server, $backends, {'backend_name' => $be_name, 'port' => $http_port})
  }
  Haproxy::Backend::Server <<| tag == "${name}_${cluster}" |>> {
    backend_name        => $be_name,
    port                => $http_port,
  }
  if $add_request_header != '' {
    create_resources(haproxy::backend::add_header, $add_request_header, {'backend_name' => $be_name, 'type' => 'req'})
  }

  haproxy::frontend {"frontend_${be_name}":
    bind                  => $bind_addresses,
    port                  => $http_port,
    default_backend       => $be_name,
    options               => $array_fe_options,
    mode                  => 'http',
    own_logfile           => $own_logfile,
    monitor               => $monitor,
    monitored_hostname    => $monitored_hostname,
    notifications_enabled => $notifications_enabled,
    notification_period   => $notification_period,
    timeout_client        => $timeout_client,
  }

  haproxy::backend::acl {"from_softec_${name}":
    acl_name      => 'from_softec',
    backend_name  => $be_name,
    condition     => "src -f ${haproxy::params::config_dir}subnet_softec.lst"
  }

  if !defined(File ["${haproxy::params::config_dir}subnet_softec.lst"]) {
    file {"${haproxy::params::config_dir}subnet_softec.lst":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '440',
      content => template('haproxy/subnet_softec.lst.erb')
    }
  }

  haproxy::backend::del_header { "X-Varnish-Debug_${name}":
    header_name   => 'X-Varnish-Debug',
    backend_name  => $be_name,
    type          => 'req',
    acl           => '!from_softec',
  }

  haproxy::backend::add_header { "X-HaProxy-Id_${name}":
    header_name   => 'X-HaProxy-Id',
    backend_name  => $be_name,
    type          => 'req',
    value         => $hostname,
    acl           => 'from_softec',
  }

  haproxy::backend::add_header { "X-Varnish-Debug_${name}":
    header_name   => 'X-Varnish-Debug',
    backend_name  => $be_name,
    type          => 'req',
    value         => '1',
    acl           => 'from_softec',
  }

  if $appsession != '' {
    # Fx: uso questa sostituzione per evitare ripetizioni. Lo stesso nome potrebbe essere utilizzato su piu' backend.
    # All'interno di haproxy::backend::appsession viene eliminata tutto cio' che e' --*--
    $array_appsession_name = regsubst($array_appsession,'$',"--$name--")

    haproxy::backend::appsession {"${array_appsession_name}" :
      backend_name  => $be_name,
      options       => ['request-learn' , 'prefix'],
    }

    haproxy::frontend::capture {$array_appsession_name :
      frontend_name => "frontend_${be_name}",
      capture_type  => 'cookie',
      length        => 52,
    }
  }

  if $cookie_capture != '' {
    # Fx: uso questa sostituzione per evitare ripetizioni. Lo stesso nome potrebbe essere utilizzato su piu' backend.
    # All'interno di haproxy::frontend::capture viene eliminata tutto cio' che e' --*--
    $array_cookie_capture_name = regsubst($array_cookie_capture,'$',"--$name--")

    haproxy::frontend::capture {$array_cookie_capture_name :
      frontend_name => "frontend_${be_name}",
      capture_type  => 'cookie',
      length        => 52,
    }
  }

  if $res_header_capture != '' {
    # Fx: uso questa sostituzione per evitare ripetizioni. Lo stesso nome potrebbe essere utilizzato su piu' backend.
    # All'interno di haproxy::frontend::capture viene eliminata tutto cio' che e' --*--
    $array_res_header_capture_name = regsubst($array_res_header_capture,'$',"--$name--")

    haproxy::frontend::capture {$array_res_header_capture_name :
      frontend_name => "frontend_${be_name}",
      capture_type  => 'response header',
      length        => 10,
    }
  }

  if $req_header_capture != '' {
    # Fx: uso questa sostituzione per evitare ripetizioni. Lo stesso nome potrebbe essere utilizzato su piu' backend.
    # All'interno di haproxy::frontend::capture viene eliminata tutto cio' che e' --*--
    $array_req_header_capture_name = regsubst($array_req_header_capture,'$',"--$name--")

    haproxy::frontend::capture {$array_req_header_capture_name :
      frontend_name => "frontend_${be_name}",
      capture_type  => 'request header',
      length        => 10,
    }
  }
}
