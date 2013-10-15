class haproxy::monitoring {
  nrpe::check_haproxy #da implementare

  @@nagios::check
}
