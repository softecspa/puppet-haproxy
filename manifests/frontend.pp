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
# [*file_template*]
#   if customized template should be used. Otherwise check backend-hostname-be_name
#
# [*defaul_backend*]
#   default backend to use
#
# [*mode*]
#   haproxy mode directive. Can be http or tcp. Default tcp
#
# [*options*]
#   array of options
#
define haproxy::frontend (
  $bind,
  $default_backend,
  $fe_name          = '',
  $file_template    = 'haproxy/haproxy_frontend_header.erb',
  $mode             = 'tcp',
  $options          = '',
  $monitor          = true,
) {

  if ($mode != 'http') and ($mode != 'tcp') {
    fail ('mode paramater must be http or tcp')
  }

  $frontend_name = $fe_name?{
    ''      => $name,
    default => $fe_name,
  }

  $array_bind = is_array($bind)? {
    true    => $bind,
    default => [ $bind ],
  }

  $array_options = is_array($options)? {
    true    => $options,
    default => [ $options ],
  }

  $string_binds = inline_template('<% array_bind.each do |bind| -%><%= bind %> <% end -%>')
  if $string_binds !~ /([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{1,5}\ )+$/ {
    fail('invalid ip_address:port value present in bind')
  }

  concat_fragment {"haproxy+003-${name}-001.tmp":
    content => template($file_template),
  }

  if $monitor {
    if $haproxy::monitor {
      nrpe::check_haproxy {$frontend_name :}

      @@nagios::check { "${frontend_name}-${::hostname}":
        host                  => $hostname,
        checkname             => 'check_nrpe_1arg',
        service_description   => "HaProxy frontend ${frontend_name}",
        notifications_enabled => 0,
        target                => "haproxy_stats_${::hostname}.cfg",
        params                => "!check_haproxy_${frontend_name}",
        tag                   => "nagios_check_haproxy_${haproxy::nagios_hostname}",
      }
    }
  }
}
