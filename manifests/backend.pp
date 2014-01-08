# = Define haproxy::backend
#
#   This define creates a fragment with backend definitions
#
# == Params
#
# [*be_name*]
#  backend's name. <name> will be used if it's not defined
#
# [*file_template*]
#   if customized template should be used. Otherwise check backend-hostname-be_name
#
# [*options*]
#   array of haproxy option to enable on this backend.
#
# [*mode*]
#   haproxy mode directive. Can be http or tcp. Default tcp
#
# [*monitor*]
#   export nagios::check resource. If monitor in haproxy class definition is false, this parameter will be ignored
#
define haproxy::backend (
  $be_name        = '',
  $file_template  = 'haproxy/haproxy_backend_header.erb',
  $options        = '',
  $mode           = 'tcp',
  $monitor        = true,
) {

  if ($mode != 'http') and ($mode != 'tcp') {
    fail ('mode paramater must be http or tcp')
  }

  $backend_name = $be_name? {
    ''      => $name,
    default => $be_name
  }

  $array_options = is_array($options)? {
    true  => $options,
    false => [ $options ]
  }

  concat_fragment {"haproxy+002-${name}-001.tmp":
    content => template($file_template),
  }

  if $monitor {
    if $haproxy::monitor {
      nrpe::check_haproxy {$backend_name :}

      @@nagios::check { "${backend_name}-${::hostname}":
        host                  => $hostname,
        checkname             => 'check_nrpe_1arg',
        service_description   => "HaProxy backend ${backend_name}",
        notifications_enabled => 0,
        target                => "haproxy_stats_${::hostname}.cfg",
        params                => "!check_haproxy_${backend_name}",
        tag                   => "nagios_check_haproxy_${haproxy::nagios_hostname}",
      }
    }
  }
}


