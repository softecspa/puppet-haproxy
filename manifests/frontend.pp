# = Define haproxy::frontend
#
#   This define creates a fragment with backend definitions
#
# == Params
#
# [*fe_name*]
#   frontend name. <name> will be used if it's not defined
#
# [*bind*]
#   Array of ip on which frontend must bind.
#
# [*port*]
#   Port on which bind
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
# [*monitor*]
#   If true, it exports nrpe::check resource. Default: true. If monitor in haproxy class definition if false this parameter will be ignored
#
# [*own_logfile*]
#   If true, requests on this frontend will be logged in a separate file under ${haproxy::log_dir}/frontend_name.log
#
define haproxy::frontend (
  $bind,
  $port,
  $default_backend,
  $fe_name                = '',
  $file_template          = 'haproxy/haproxy_frontend_header.erb',
  $mode                   = 'tcp',
  $options                = '',
  $monitor                = true,
  $own_logfile            = false,
  $monitored_hostname     = $::hostname,
  $notifications_enabled  = undef,
  $notification_period    = undef,
  $timeout_client         = '',
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
  if ($string_binds !~ /([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\ )+$/) and ($string_binds !~ /.*\..+$/) {
    fail('invalid ip_address value present in bind')
  }

  concat_fragment {"haproxy+003-${name}-001-1.tmp":
    content => template($file_template),
  }

  if $timeout_client != '' {
    concat_fragment {"haproxy+003-${name}-001-2.tmp":
      content => "    timeout client $timeout_client"
    }
  }

  if $monitor {
    if $haproxy::monitor {
      nrpe::check_haproxy {$frontend_name :}

      $nrpe_check_name = $monitored_hostname? {
        $::hostname => "!check_haproxy_${frontend_name}",
        default     => "!check_haproxy_${frontend_name}_${::hostname}"
      }

      $service_description = $monitored_hostname? {
        $::hostname => "HaProxy ${frontend_name}",
        default     => "${::hostname} HaProxy ${frontend_name}",
      }

      @@nagios::check { "${frontend_name}-${::hostname}":
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

  $facility_ensure = $haproxy::log_dir? {
    ''      => 'absent',
    default => $own_logfile? {
      true  => 'present',
      false => 'absent',
    }
  }

  softec_rsyslog::imfile { "haproxy_${frontend_name}":
    ensure        => $own_logfile ? {
        true  => 'present',
        false => 'absent',
    },
    order         => '10',
    file_name     => "haproxy_${frontend_name}.log",
    file_dir      => $haproxy::log_dir,
    template      => 'haproxy/rsyslog_facility_frontend.erb',
    logrotate     => false,
    file_tag      => $frontend_name,
  }
}
