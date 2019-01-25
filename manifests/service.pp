# == Class splunkforwarder::service
#
# This class is meant to be called from splunkforwarder.
# It ensure the service is running.
#
class splunkforwarder::service inherits splunkforwarder {
  # splunk service
  service { 'splunk':
    ensure     => $splunkforwarder::service_ensure,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    start      => "${splunkforwarder::home_dir}/bin/splunk start",
    stop       => "${splunkforwarder::home_dir}/bin/splunk stop",
    status     => "${splunkforwarder::home_dir}/bin/splunk status",
    restart    => "${splunkforwarder::home_dir}/bin/splunk restart",
  }
}
