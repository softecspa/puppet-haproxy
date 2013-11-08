class haproxy::service {

  service {$haproxy::params::service_name :
    ensure      => $haproxy::service_ensure,
    enable      => $haproxy::service_enable,
    hasrestart  => true,
    hasstatus   => true,
  }

  exec {"${haproxy::params::service_name} reload":
    command     => "/etc/init.d/${haproxy::params::service_name} reload",
    refreshonly => true,
    subscribe   => Concat_build['haproxy']
  }

}
