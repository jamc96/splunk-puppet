# == Class splunkforwarder::service
#
# This class is meant to be called from splunkforwarder.
# It ensure the service is running.
#
class splunkforwarder::service(
    String $service_name        = $::splunkforwarder::service_name,
    String $service_ensure      = $::splunkforwarder::service_ensure,
    Boolean $service_enable     = $::splunkforwarder::service_enable,
    Boolean $service_hasstatus  = $::splunkforwarder::service_hasstatus,
    Boolean $service_hasrestart = $::splunkforwarder::service_hasrestart,
    String $run_dir             = $::splunkforwarder::run_dir,
    String $pid_selinux         = $::splunkforwarder::pid_selinux,
  ) {
  service { $service_name:
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasstatus  => $service_hasstatus,
    hasrestart => $service_hasrestart,
  }
}
