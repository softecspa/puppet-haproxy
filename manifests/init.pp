# = Class haproxy
#
# This class install HaProxy with some configurable params
#
# == Params
#
# [*service_ensure*]
#   status of the service. Boolean or running|stopped. Default: running
#
# [*service_enable*]
#   service enabled by default. Boolean. Default: true
#
# [*log_dir*]
#   false do not log on file. otherwise path of directory where haproxy should log (syslog_facility become mandatory). If not false logrotate will be enabled. Default: /var/log/haproxy
#
# [*logserver*]
#   syslog server address. Default: 127.0.0.1
#
# [*file_template*]
#   template used to override default configuration
#
# [*syslog_facility*]
#   facility used to log on rsyslog. Default: local1
#
# [*enable_stats*]
#   enable stats page. Default: true
#
# [*enable_hatop*]
#   enable hatop by installing package and setting user/group to root. Default: true
#
# [*maxconn*]
#   global maxconn
#
# [*contimeout*]
#   haproxy param. Default: 5000
#
# [*clitimeout*]
#   haproxy param. Default: 50000
#
# [*srvtimeout*]
#   haproxy param. Default: 50000
#
# [*retries*]
#   haproxy param. Default: 3
#
# [*default_mode*]
#   default mode of use. It can be tcp|http. Default: tcp
#
# [*options*]
#   array of options to enable on global section. Default: ''
#
# [*stats_user*]
#   username to use for access stats. Default: haproxystats
#
# [*stats_pass*]
#  password to user for access stats
#
# [*monitor*]
#   enable monitor of process haproxy and hastats
#
# [*nagios_hostname*]
#   hostname of nagios server used for monitoring. Default: global variable $nagios_hostname
#
class haproxy (
  $service_ensure   = running,
  $service_enable   = true,
  $log_dir          = '/var/log/haproxy',
  $logserver        = '127.0.0.1',
  $file_template    = '',
  $syslog_facility  = 'local1',
  $enable_hatop     = true,
  $maxconn          = 2000,
  $contimeout       = 5000,
  $clitimeout       = 50000,
  $srvtimeout       = 50000,
  $retries          = 2,
  $srvtimeout       = 50000,
  $default_mode     = 'tcp',
  $options          = '',
  $enable_stats     = true,
  $stats_user       = 'haproxystats',
  $stats_pass       = '',
  $stats_port       = '1936',
  $stats_uri        = '/haproxy?stats',
  $stats_hide       = true,
  $stats_realm      = 'Haproxy\ Statistics',
  $monitor          = true,
  $nagios_hostname  = $nagios_hostname,
) {

  include haproxy::params

  if $log_dir != false {
    validate_absolute_path($log_dir)
  }

  validate_bool($enable_stats)
  validate_bool($enable_hatop)
  validate_bool($monitor)
  validate_bool($service_enable)

  if ($service_ensure != false) and ($service_ensure != true) and ($service_ensure != 'running') and ($service_ensure != 'stopped') {
    fail ('service_ensure must be boolean or running|stopped')
  }

  if !is_integer($maxconn) {
    fail ('maxconn should be an integer value')
  }

  if !is_integer($contimeout) {
    fail ('contimeout should be an integer value')
  }

  if !is_integer($clitimeout) {
    fail ('clitimeout should be an integer value')
  }

  if !is_integer($srvtimeout) {
    fail ('srvtimeout should be an integer value')
  }

  if ($default_mode != 'http') and ($default_mode != 'tcp') {
    fail ('default_mode must be one of http|tcp')
  }

  if ($enable_stats and (($stats_user == '') or ($stats_pass == ''))) {
    fail('if enable_stats is true you must specify stats_user and stats_pass')
  }

  if ($monitor) and ($nagios_hostname=='') {
    fail ('if monitor is true you have to specify nagios_hostname')
  }

  if !$syslog_facility {
    fail ('Please specify a syslog_facility')
  }

  $array_options = is_array($options)? {
    true  => $options,
    false => [ $options ]
  }

  $haproxy_user_group = $enable_hatop ? {
    true  => 'root',
    false => 'haproxy'
  }

  if $log_dir != '' {
    rsyslog::facility { '11-haproxy':
      log_file      => "haproxy.log",
      logdir        => $log_dir,
      file_template => 'haproxy/rsyslog_facility.erb',
      create        => '644 syslog adm',
      logrotate     => false
    }
    include haproxy::logrotate
  }

  include haproxy::install
  include haproxy::config
  include haproxy::service

  Class['haproxy::install'] ->
  Class['haproxy::config'] ->
  Class['haproxy::service']


  if defined(Class['heartbeat']) {
    Class['heartbeat'] ->
    Class['haproxy::service']
  }

  if defined(Class['datadog']) {
    include haproxy::datadog
  }

}
