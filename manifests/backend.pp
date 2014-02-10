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
  $be_name                = '',
  $file_template          = 'haproxy/haproxy_backend_header.erb',
  $options                = '',
  $mode                   = 'tcp',
  $monitor                = true,
  $monitored_hostname     = $::hostname,
  $notifications_enabled  = undef,
  $notification_period    = undef,
  $timeout_connect        = '',
  $timeout_client         = '',
  $timeout_server         = '',
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

  concat_fragment {"haproxy+002-${name}-001-1.tmp":
    content => template($file_template),
  }

  if $timeout_connect != '' {
    concat_fragment {"haproxy+002-${name}-001-2.tmp":
      content => "    timeout connect $timeout_connect"
    }
  }

  if $timeout_server != '' {
    concat_fragment {"haproxy+002-${name}-001-3.tmp":
      content => "    timeout server $timeout_server"
    }
  }

  if $timeout_client != '' {
    concat_fragment {"haproxy+002-${name}-001-4.tmp":
      content => "    timeout client $timeout_client"
    }
  }

  if $monitor {
    if $haproxy::monitor {
      nrpe::check_haproxy {$backend_name :}

      $nrpe_check_name = $monitored_hostname? {
        $::hostname => "!check_haproxy_${backend_name}",
        default     => "!check_haproxy_${backend_name}_${::hostname}"
      }

      $service_description = $monitored_hostname? {
        $::hostname => "HaProxy backend ${backend_name}",
        default     => "${::hostname} HaProxy backend ${backend_name}",
      }

      @@nagios::check { "${backend_name}-${::hostname}":
        host                  => $monitored_hostname,
        checkname             => 'check_nrpe_1arg',
        service_description   => $service_description,
        notifications_enabled => $notifications_enabled,
        notification_period   => $notification_period,
        target                => "haproxy_stats_${::hostname}.cfg",
        params                => $nrpe_check_name,
        tag                   => "nagios_check_haproxy_${haproxy::nagios_hostname}",
      }
    }
  }
}


