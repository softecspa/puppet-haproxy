# = Define haproxy::listen
#
#   This define creates a fragment with listen definition
#
# == Params
#
# [*listen_name*]
#  use name if this isn't defined
#
# [*bind*]
#  ip:port or ip:port-range
#
# [*file_template*]
#   if customized template should be used. Otherwise check backend-hostname-be_name
#
# [*mode*]
#   haproxy mode directive. Can be http or tcp. Default tcp
#
# [*options*]
#   array of options
#
define haproxy::listen (
  $bind,
  $port,
  $listen_name          = '',
  $file_template    = 'haproxy/haproxy_listen_header.erb',
  $mode             = 'tcp',
  $options          = '',
  $monitor          = true,
) {

  if ($mode != 'http') and ($mode != 'tcp') {
    fail ('mode paramater must be http or tcp')
  }

  $ls_name = $listen_name?{
    ''      => $name,
    default => $listen_name,
  }

  $array_options = is_array($options)? {
    true    => $options,
    default => [ $options ],
  }

  if $bind !~ /[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/ {
    fail('invalid ip_address value present in bind')
  }

  concat_fragment {"haproxy+004-${name}-001.tmp":
    content => template($file_template),
  }

  if $monitor {
    if $haproxy::monitor {
      nrpe::check_haproxy {$ls_name :}

      @@nagios::check { "${ls_name}-${::hostname}":
        host                  => $hostname,
        checkname             => 'check_nrpe_1arg',
        service_description   => "HaProxy listen ${ls_name}",
        notifications_enabled => 0,
        target                => "haproxy_stats_${::hostname}.cfg",
        params                => "!check_haproxy_${ls_name}",
        tag                   => "nagios_check_haproxy_${haproxy::nagios_hostname}",
      }
    }
  }
}
