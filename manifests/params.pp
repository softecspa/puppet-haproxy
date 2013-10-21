class haproxy::params {

  $package_name       = 'haproxy'
  $hatop_package_name = 'hatop'
  $sock               = '/var/run/haproxy/haproxy.sock'
  $config_dir         = '/etc/haproxy/'
  $default_config     = '/etc/default/haproxy'
}
