# = Define haproxy::backend::add_header
#
#   add a header to request or response
#
# == Params
#
# [*header_name*]
#   Name of the header to add. <name> will be used if it's not set.
#
# [*backend_name*]
#   name of haproxy::backend resource to rely
#
# [*file_template*]
#   if customized template should be used to override default template.
#
# [*type*]
#   req|resp. Default: req
#
# [*value*]
#   value of the header to add
#
define haproxy::backend::add_header (
  $backend_name,
  $header_name    = '',
  $file_template  = 'haproxy/backend/add_header.erb',
  $type           = 'req',
  $value          = '',
) {

  if !defined(Haproxy::Backend[$backend_name]) {
    fail ("No Haproxy::Backend[$backend_name] is defined!")
  }

  if ($type != 'req') and ($type != 'resp') {
    fail('Type must be req|resp. Please specify correctly!')
  }

  $header = $header_name ? {
    ''      => $name,
    default => $header_name,
  }

  $command = $type? {
    'req'   => 'reqadd',
    'resp'  => 'rspadd',
  }

  $header_value = $value? {
    ''      => $value,
    default => ":\\ $value",
  }

  concat_fragment {"haproxy+002-${backend_name}-003-${name}.tmp":
    content => template($file_template),
  }


}
