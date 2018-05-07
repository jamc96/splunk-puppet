# == Class splunkforwarder::service
#
# This class is meant to be called from splunkforwarder.
# It ensure the service is running.
#
class splunkforwarder::service(
  $service_name        = $::splunkforwarder::service_name,
  $service_ensure      = $::splunkforwarder::service_ensure,
  ) {
  service { $service_name:
    ensure     => $service_ensure,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
