# = Define haproxy::backend
#
#   This define creates a fragment with backend definitions
#
# == Params
#
# [*be_name*]
#  if name isn't defined
#
# [*template*]
#   if customized template should be used. Otherwise check backend-hostname-be_name
#
# [*appsession*]
#   hash for appsession to use
#
# [*add_request_header*]
#   hash of request headers to add
#
# [*servers]
#   hash of address:port anche checks options
#
# [*options*]
#   array of options
