# = Define haproxy::frontend
#
#   This define creates a fragment with backend definitions
#
# == Params
#
# [*fe_name*]
#  use name if this isn't defined
#
# [*bind*]
#  Array of ip:port
#
# [*template*]
#   if customized template should be used. Otherwise check backend-hostname-be_name
#
# [*defaul_backend*]
#   default backend to use
#
# [*options*]
#   array of options
