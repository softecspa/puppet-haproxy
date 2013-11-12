define haproxy::rsyslog_facility (
  $description,
  $logdir,
  $log_file,
  $file_template,
  $logrotate,
  $rotate,
  $retention_days,
  $create,
  $addresses,
) {

  if !defined(Rsyslog::Facility[$description]) {
    rsyslog::facility{ $description :
      logdir          => $logdir,
      log_file        => $log_file,
      file_template   => $file_template,
      logrotate       => $logrotate,
      rotate          => $rotate,
      retention_days  => $retention_days,
      create          => $create
    }
  }
}
