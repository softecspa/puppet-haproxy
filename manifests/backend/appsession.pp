# = Define haproxy::backend::appsession
#
#   add appsession on specified backend
#
# == Params
#
# [*cookie_name*]
#   if blank use <name>
#
# [*backend_name*]
#   name of haproxy::backend to rely
#
# [*length*]
#
# [*timeout*]
#
# [*options*]
#
define haproxy::backend::appsession (
  $backend_name,
  $cookie_name      = '',
  $file_template    = 'haproxy/backend/appsession.erb',
  $length           = 52,
  $session_timeout  = '30m',
  $options          = '',
) {

  if !defined(Haproxy::Backend[$backend_name]) {
    fail ("No Haproxy::Backend[$backend_name] is defined!")
  }

  $appsession_cookie= $cookie_name? {
    ''      => $name,
    default => $cookie_name,
  }

  $array_options = is_array($options)? {
    true    => $options,
    default => [ $options ]
  }

  concat_fragment{"haproxy+002-${backend_name}-002-${name}.tmp":
    content => template($file_template),
  }

}
