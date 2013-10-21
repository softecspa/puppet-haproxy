# = Define haproxy::frontend::capture
#
#   capture header or cookie for logging
#
# == Params
#
# [*capture_name*]
#   if blank use <name>
#
# [*file_template*]
#   template to override with customized feature
#
# [*frontend_name*]
#   name of haproxy::frontend to rely
#
# [*type*]
#   cookie|respose header|request header
#
# [*length*]
#   integer
#
define haproxy::frontend::capture (
  $frontend_name,
  $file_template  = 'haproxy/frontend/capture.erb',
  $capture_name   = '',
  $capture_type   = 'cookie',
  $length         = 52,
) {

  if !defined(Haproxy::Frontend[$frontend_name]) {
    fail ("No Haproxy::Frontend[$frontend_name] is defined!")
  }

  if ($capture_type != 'cookie') and ($capture_type != 'request header') and ($capture_type != 'response header') {
    fail ('type can only be: cookie | request header | response header')
  }

  if !is_integer($length) {
    fail ('Errore must ba an integer value')
  }

  $capture = $capture_name ? {
    ''      => $name,
    default => $capture_name,
  }

  concat_fragment {"haproxy+003-${frontend_name}-002-${name}.tmp":
    content => template($file_template)
  }
}
