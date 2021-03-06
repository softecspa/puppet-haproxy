# = Define haproxy::listen::server
#
#   add a server on specified listen
#
# == Params
#
# [*listen_name*]
#   name of haproxy::listen resource to rely
#
# [*server_name*]
#   Server name to use
#
# [*server_check*]
#   Boolen. If true HaProxy will performs healt checks on the server. Default: true
#
# [*file_template*]
#   if customized template should be used to override default template.
#
# [*bind*]
#   ip of the server
#
# [*port*]
#   port used to contact the server
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
# [*check_port*]
#   Port used to check backend
#
define haproxy::listen::server (
  $listen_name,
  $bind,
  $file_template= 'haproxy/listen/server.erb',
  $server_name  = '',
  $server_check = true,
  $inter        = '5s',
  $downinter    = '1s',
  $fastinter    = '1s',
  $rise         = 2,
  $fall         = 3,
  $backup       = false,
  $send_proxy   = false,
  $port         = '',
  $check_port   = '',
) {

  if !defined(Haproxy::Listen[$listen_name]) {
    fail ("No Haproxy::Listen[$listen_name] is defined!")
  }


  if ( $bind !~ /[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/) {
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
    content => template($file_template),
  }
}
