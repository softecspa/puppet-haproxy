# = Define haproxy::frontend::use_backend
#
# This define add a use_backend directive if an acl is matched
#
# == Parameters
#
# [*frontend_name*]
#   name of haproxy::frontend to rely
#
# [*backend_name*]
#   backend to use id specified acl is matched
#
# [*if_acl*]
#   acl name that nedd to be matched
#
# [*file_template*]
#   template to use for override default template
#
define haproxy::frontend::use_backend (
  $frontend_name,
  $backend_name,
  $if_acl,
  $file_template  = 'haproxy/frontend/use_backend.erb'
) {

  if !defined(Haproxy::Frontend[$frontend_name]) {
    fail ("No Haproxy::Frontend[$frontend_name] is defined!")
  }

  concat_fragment { "haproxy+003-${frontend_name}-004-${name}.tmp":
    content => template($file_template),
  }
}
