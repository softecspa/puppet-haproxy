# = Class haproxy
#
# This class install HaProxy with some configurable params
#
# == Params
#
# [*monitor*]
#   enable monitor of process haproxy and hastats
#
# [*static_config*]
#   if this is used, all other parameters will be ignored and static file is pushed. File to be pushed will be retrieved under this convention:
#     * haproxy.conf_$fqdn
#     * haproxy-conf_$cluster
#     * haproxy.conf
#
# [*log_file*]
#   false do not log on file. otherwise pathfile (syslog_facility become mandatory). If file enable logrotate
#
# [*syslog_facility*]
#   facility to use for redirect rsyslog log
#
# [*enable_stats*]
#   enable stats page
#
# [*enable_hatop*]
#   enable hatop by installing package and setting user/group
#
# [*enabled*]
#   service must be enabled by default. Default: true
#
# [*running*]
#   service must be running
#
# [*maxconn*]
#   global maxconn
#
# [*mode*]
#   defaults mode
#
# [*options*]
#   default options array
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
# [*enable_hatop*]
#   install hatop and start service as root
#
# [*enable_stats*]
#   Abilita pagina di stats
#
# [*stats_user*]
#   stats username
#
# [*stats_pass*]
#  stats password
#
if ($log_file!='') {
  include haproxy::logrotate
}

if ($monitor) {
  include haproxy::monitoring
}
