class haproxy::params {

  $package_name       = 'haproxy'
  $hatop_package_name = 'hatop'
  $socat_package_name = 'socat'
  $sock               = '/var/run/haproxy.sock'
  $config_dir         = '/etc/haproxy/'
  $default_config     = '/etc/default/haproxy'
  $service_name       = 'haproxy'
  $archive_logdir     = '/var/log'
  $errorpages_dir     = "${config_dir}errors/"
}
