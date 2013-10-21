# = Define haproxy::frontend::acl
#
# This define add an haproxy acl on frontend section
#
# == Parameters
#
# [*frontend_name*]
#   name of haproxy::frontend to rely
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
define haproxy::frontend::acl (
  $frontend_name,
  $condition,
  $acl_name       = '',
  $use_backend    = '',
  $file_template  = 'haproxy/frontend/acl.erb'
) {

  if !defined(Haproxy::Frontend[$frontend_name]) {
    fail ("No Haproxy::Frontend[$frontend_name] is defined!")
  }

  $acl = $acl_name ? {
    ''      => $name,
    default => $acl_name,
  }

  concat_fragment { "haproxy+003-${frontend_name}-003-${name}.tmp":
    content => template($file_template)
  }

  if ($use_backend!='') {
    if !defined(Haproxy::Backend[$use_backend]) {
      fail ("No Haproxy::Backend[$use_backend] is defined!")
    }

    haproxy::frontend::use_backend { "${use_backend}-${acl}":
      frontend_name => $frontend_name,
      backend_name  => $use_backend,
      if_acl        => $acl,
    }
  }


}
