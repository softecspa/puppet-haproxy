# = Define haproxy::listen
#
#   This define creates a fragment with listen definition
#
# == Params
#
# [*listen_name*]
#  use name if this isn't defined
#
# [*bind*]
#  ip:port or ip:port-range
#
# [*file_template*]
#   if customized template should be used. Otherwise check backend-hostname-be_name
#
# [*mode*]
#   haproxy mode directive. Can be http or tcp. Default tcp
#
# [*options*]
#   array of options
#
define haproxy::listen (
  $bind,
  $listen_name          = '',
  $file_template    = 'haproxy/haproxy_listen_header.erb',
  $mode             = 'tcp',
  $options          = ''
) {

  if ($mode != 'http') and ($mode != 'tcp') {
    fail ('mode paramater must be http or tcp')
  }

  $ls_name = $listen_name?{
    ''      => $name,
    default => $listen_name,
  }

  $array_options = is_array($options)? {
    true    => $options,
    default => [ $options ],
  }

  if $bind !~ /[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{1,5}(-[0-9]{1,5})?$/ {
    fail('invalid ip_address:port or ip_address::portrange value present in bind')
  }

  concat_fragment {"haproxy+004-${name}-001.tmp":
    content => template($file_template),
  }


}
