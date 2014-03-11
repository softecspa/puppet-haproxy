# = Define haproxy::backend::del_header
#
#   delete a header from request or response
#
# == Params
#
# [*header_name*]
#   Name of the header to delete. <name> will be used if it's not set.
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
# [*acl*]
#   add "if <acl>" to the endof line. Only if specified acl is matched, header will be deleted
#
define haproxy::backend::del_header (
  $backend_name,
  $header_name    = '',
  $file_template  = 'haproxy/backend/del_header.erb',
  $type           = 'req',
  $acl            = '',
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
    'req'   => 'reqdel',
    'resp'  => 'rspdel',
  }

  concat_fragment {"haproxy+002-${backend_name}-004-${name}.tmp":
    content => template($file_template),
  }


}
