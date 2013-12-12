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
# [*global_maxconn*]
#   Sets the maximum number of concurrent connections.
#
# [*frontend_maxconn*]
#   Fix the default maximum number of concurrent connections on a frontend
#
# [*connect_timeout*]
#   haproxy param. The maximum time in milliseconds to wait for a connection attempt to a server to succeed. Default: 2000
#
# [*client_timeout*]
#   haproxy param. The maximum inactivity time in milliseconds on the client side. Default: 20000
#
# [*server_timeout*]
#   haproxy param. The Maximum inactivity time in milliseconds on the server side. Default: 20000
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
# [*custom_errorpages*]
#   if defined, errorpages pushed will be searched under files/<code_error>_$custom_errorpages.html. If not define default file will be pushed
#
class haproxy (
  $service_ensure   = running,
  $service_enable   = true,
  $log_dir          = '/var/log/haproxy',
  $logserver        = '127.0.0.1',
  $file_template    = '',
  $syslog_facility  = 'local1',
  $enable_hatop     = true,
  $global_maxconn   = 20000,
  $frontend_maxconn = 18000,
  $connect_timeout  = 10000,
  $client_timeout   = 20000,
  $server_timeout   = 20000,
  $retries          = 2,
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
  $user             = 'haproxy',
  $group            = 'haproxy',
  $custom_errorpages= 'default',
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

  if !is_integer($global_maxconn) {
    fail ('global_maxconn should be an integer value')
  }

  if !is_integer($frontend_maxconn) {
    fail ('frontend_maxconn should be an integer value')
  }

  if !is_integer($connect_timeout) {
    fail ('connect_timeout should be an integer value')
  }

  if !is_integer($client_timeout) {
    fail ('client_timeout should be an integer value')
  }

  if !is_integer($server_timeout) {
    fail ('server_timeout should be an integer value')
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

  #if defined(Class['datadog']) {
  #  include haproxy::datadog
  #  notify {'test':}
  #} else {
  #  notify {'test2':}
  #}

}
