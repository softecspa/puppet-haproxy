# = Define haproxy::listen
#
#   This define creates a fragment with listen definition
#
# == Params
#
# [*listen_name*]
#  name of listen. <name> will be used it it's not specified
#
# [*bind*]
#  ip to bind
#
# [*port*]
#  port or port range to bind
#
# [*file_template*]
#   if customized template should be used to override default template.
#
# [*mode*]
#   haproxy mode directive. Can be http or tcp. Default tcp
#
# [*options*]
#   array of options to use on this listen block
#
# [*monitor*]
#   If true, it exports nrpe::check resource. Default: true. If monitor parame in haproxy class definition is false this parameter will be ignored
#
define haproxy::listen (
  $bind,
  $port,
  $listen_name            = '',
  $file_template          = 'haproxy/haproxy_listen_header.erb',
  $mode                   = 'tcp',
  $options                = '',
  $monitor                = true,
  $monitored_hostname     = $::hostname,
  $notifications_enabled  = undef,
  $notification_period    = undef,
  $timeout_connect        = '',
  $timeout_server         = '',
  $timeout_client         = '',
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

  concat_fragment {"haproxy+004-${name}-001-1.tmp":
    content => template($file_template),
  }

  if $timeout_connect != '' {
    concat_fragment {"haproxy+004-${name}-001-2.tmp":
      content => "    timeout connect $timeout_connect"
    }
  }

  if $timeout_server != '' {
    concat_fragment {"haproxy+004-${name}-001-3.tmp":
      content => "    timeout server $timeout_server"
    }
  }

  if $timeout_client != '' {
    concat_fragment {"haproxy+004-${name}-001-4.tmp":
      content => "    timeout client $timeout_client"
    }
  }

  if $monitor {
    if $haproxy::monitor {
      nrpe::check_haproxy {$ls_name :}

      $nrpe_check_name = $monitored_hostname? {
        $::hostname => "!check_haproxy_${ls_name}",
        default     => "!check_haproxy_${ls_name}_${::hostname}"
      }

      $service_description = $monitored_hostname? {
        $::hostname => "HaProxy listen ${ls_name}",
        default     => "${::hostname} HaProxy listen ${ls_name}",
      }

      @@nagios::check { "${ls_name}-${::hostname}":
        host                  => $monitored_hostname,
        checkname             => 'check_nrpe_1arg',
        service_description   => $service_description,
        notifications_enabled => $notifications_enabled,
        notification_period   => $notification_period,
        target                => "haproxy_stats_${::hostname}.cfg",
        params                => "!check_haproxy_${ls_name}",
        tag                   => "nagios_check_haproxy_${haproxy::nagios_hostname}",
      }
    }
  }
}
