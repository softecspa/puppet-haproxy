# = Define haproxy::listen::server
#
#   add a server on specified listen
#
# == Params
#
# [*check*]
#   true|false
#
# [*listen_name*]
#   name of haproxy::liste to rely
#
# [*bind*]
#   ip:port of the server
#
# [*inter*]
#
# [*downinter*]
#
# [*fastinter*]
#
# [*rise*]
#
# [*fall*]
#
# [*backup*]
#   true is the server have to work as backup. Default: false
#
# [*send_proxy*]
#   True if the send_proxy directive must be added. Default: false
#
define haproxy::listen::server (
  $listen_name,
  $bind,
  $file_template= 'haproxy/listen/server.erb',
  $server_name  = '',
  $server_check = true,
  $inter        = '2s',
  $downinter    = '1s',
  $fastinter    = '1s',
  $rise         = 2,
  $fall         = 3,
  $backup       = false,
  $send_proxy   = false,
) {

  if !defined(Haproxy::Listen[$listen_name]) {
    fail ("No Haproxy::Listen[$listen_name] is defined!")
  }


  if ( $bind !~ /[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]{2,5})?$/) {
    fail('bind must contain a valid ip address, eventually followeb by :port. Ex: 192.168.1.1:80 or 192.168.1.1')
  }

  validate_bool($server_check)
  validate_bool($backup)
  validate_bool($send_proxy)

  if !is_integer($rise) {
    fail('rise parameter must be an integer value')
  }

  if !is_integer($fall) {
    fail('fall parameter must be an integer value')
  }

  if $inter !~ /[0-9]{1,3}s/ {
    fail('inter parameter must be an integer followed by s (seconds)')
  }

  if $downinter !~ /[0-9]{1,3}s/ {
    fail('downinter parameter must be an integer followed by s (seconds)')
  }

  if $fastinter !~ /[0-9]{1,3}s/ {
    fail('fastinter parameter must be an integer followed by s (seconds)')
  }

  $servername = $server_name ? {
    ''      => $name,
    default => $server_name,
  }

  concat_fragment {"haproxy+004-${listen_name}-002-${name}.tmp":
    content => template($file_template)
  }
}
