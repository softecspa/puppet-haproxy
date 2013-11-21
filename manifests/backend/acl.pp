# = Define haproxy::frontend::acl
#
# This define add an haproxy acl on frontend section
#
# == Parameters
#
# [*frontend_name*]
#   name of haproxy::frontend resource to rely
#
# [*acl_name*]
#   acl name. If not specified <name> will be used
#
# [*condition*]
#   condition that must be satisfied to match acl
#
# [*use_backend*]
#   backend to use if acl if matched
#
# [*file_template*]
#   if customized template should be used to override default template.
#
define haproxy::backend::acl (
  $backend_name,
  $condition,
  $acl_name       = '',
  $file_template  = 'haproxy/frontend/acl.erb'
) {

  if !defined(Haproxy::Backend[$backend_name]) {
    fail ("No Haproxy::Backend[$backend_name] is defined!")
  }

  $acl = $acl_name ? {
    ''      => $name,
    default => $acl_name,
  }

  concat_fragment { "haproxy+002-${backend_name}-003-${name}.tmp":
    content => template($file_template),
  }
}
