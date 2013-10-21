class haproxy::service {

  service {'haproxy':
    ensure      => $haproxy::service_ensure,
    enable      => $haproxy::service_enable,
    hasrestart  => true,
    hasstatus   => true,
  }

}
