# = Define haproxy::backend::appsession
#
#   add appsession on specified backend
#
# == Params
#
# [*cookie_name*]
#   Name of app cookie used to manage sticky session. <name> will be used if it's not set.
#
# [*backend_name*]
#   name of haproxy::backend to rely
#
# [*file_template*]
#   if customized template should be used to override default template.
#
# [*length*]
#   Maximum number of character. Default: 52
#
# [*session_timeout*]
#   Time after which session will be considered timeout. Default: 30m
#
# [*options*]
#   Array of options used for this directive. Please refeer to official HaProxy documentation to see which options tou can use.
#
define haproxy::backend::appsession (
  $backend_name,
  $cookie_name      = '',
  $file_template    = 'haproxy/backend/appsession.erb',
  $length           = 52,
  $session_timeout  = '60m',
  $options          = '',
) {

  if !defined(Haproxy::Backend[$backend_name]) {
    fail ("No Haproxy::Backend[$backend_name] is defined!")
  }

  $appsession_cookie_name = $cookie_name? {
    ''      => $name,
    default => $cookie_name,
  }

  # Elimino eventuali suffissi aggiunti da haproxy::http_balance
  $appsession_cookie=regsubst($appsession_cookie_name,'--.*--$','')

  $array_options = is_array($options)? {
    true    => $options,
    default => [ $options ]
  }

  concat_fragment{"haproxy+002-${backend_name}-002-${name}.tmp":
    content => template($file_template),
  }

}
