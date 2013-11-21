# = Define haproxy::backend::server
#
#   add a server on specified backend
#
# == Params
#
# [*backend_name*]
#   name of haproxy::backend resource to rely
#
# [*bind*]
#   ip of the server
#
# [*port*]
#   port to use to contact server.
#
# [*file_template*]
#   if customized template should be used to override default template.
#
# [*server_name*]
#   name of server
#
# [*server_check*]
#   Boolean. If true HaProxy will perform healt check on this server. Default: true
#
# [*inter*]
#   Interval between two checks. Format: integer followed by a time suffix. Default: 5s
#
# [*downinter*]
#   interval between two checks on a down hosts. Format: same of inter. Default: 1s
#
# [*fastinter*]
#   interval between two checks when a host is coming back up. Format: same of inter. Default: 1s
#
# [*rise*]
#   Number of positive healt checks needed to consider a server up. Default: 2
#
# [*fall*]
#   Number of negative healt checks needed to consider a server down. Default: 3
#
# [*backup*]
#   true is the server have to work as backup. Default: false
#
# [*send_proxy*]
#   True if the send_proxy directive must be added. Default: false.
#
# [*weight*]
#   Weight to assign to server. interval 0(disabled) - 256 (maximum). Integer. Default: 100
#
define haproxy::backend::server (
  $backend_name,
  $bind,
  $port,
  $file_template= 'haproxy/backend/server.erb',
  $server_name  = '',
  $server_check = true,
  $inter        = '5s',
  $downinter    = '1s',
  $fastinter    = '1s',
  $rise         = 2,
  $fall         = 3,
  $backup       = false,
  $send_proxy   = false,
  $weight       = '100',
) {

  if !defined(Haproxy::Backend[$backend_name]) {
    fail ("No Haproxy::Backend[$backend_name] is defined!")
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

  if !is_integer($weight) {
    fail('weight parameter must be an integer value')
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

  $bind_address = $port? {
    ''      => $bind,
    default => "${bind}:${port}",
  }

  concat_fragment {"haproxy+002-${backend_name}-005-${name}.tmp":
    content => template($file_template),
  }
}
