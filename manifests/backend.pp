# = Define haproxy::backend
#
#   This define creates a fragment with backend definitions
#
# == Params
#
# [*be_name*]
#  if name isn't defined
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
define haproxy::backend (
  $be_name        = '',
  $file_template  = 'haproxy/haproxy_backend_header.erb',
  $options        = '',
  $mode           = 'tcp',
) {

  if ($mode != 'http') and ($mode != 'tcp') {
    fail ('mode paramater must be http or tcp')
  }

  $backend_name = $be_name? {
    ''      => $name,
    default => $be_name
  }

  $array_options = is_array($options)? {
    true  => $options,
    false => [ $options ]
  }

  concat_fragment {"haproxy+002-${name}-001.tmp":
    content => template($file_template),
  }

}


