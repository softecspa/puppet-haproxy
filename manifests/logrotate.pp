# = Class haproxy::logrotate
#
# This class enable logorotate of logfile created by haproxy
#
#
#
#
#
class haproxy::logrotate {
  logrotate::file { 'haproxy':
    log           =>  "${haproxy::log_dir}/haproxy.log",
    interval      =>  'daily',
    rotation      =>  '930',
    options       =>  [ 'missingok', 'compress', 'notifempty', 'sharedscripts' ],
    archive       =>  true,
    olddir        =>  "${haproxy::log_dir}/archives",
    olddir_owner  =>  'root',
    olddir_group  =>  'users',
    olddir_mode   =>  '655',
    create        =>  '640 syslog adm',
    postrotate    =>  'invoke-rc.d haproxy reload',
  }
}
