# == Class splunkforwarder::params
#
# This class is meant to be called from splunkforwarder.
# It sets variables according to platform.
#
class splunkforwarder::params {
  $server             = 'splunk'
  $port               = '9997'
  $local_server       = $::hostname
  $home_dir           = '/opt/splunkforwarder'
  $config_dir         = "${home_dir}/etc/system/local"
  $run_dir            = "${home_dir}/var/run"
  $user               = 'splunk'
  $config_ensure      = 'present'
  $config_owner       = 'splunk'
  $config_group       = 'splunk'
  $pid_selinux        = 'unconfined_u'
  $service_ensure     = 'running'
  $service_enable     = true
  $service_hasstatus  = true
  $service_hasrestart = true
  case $::osfamily {
    'Debian': {
      $package_name = 'splunkforwarder'
      $service_name = 'splunk'
      $source_root  = "/tmp/${package_name}"
    }
    'RedHat', 'Amazon': {
      $package_name = 'splunkforwarder'
      $service_name = 'splunk'
      $source_root  = "/tmp/${package_name}.rpm"
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
