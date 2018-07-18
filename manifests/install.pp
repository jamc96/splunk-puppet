# == Class splunkforwarder::install
#
# This class is called from splunkforwarder for install.
#
class splunkforwarder::install inherits splunkforwarder {
  # splunk package
  package { $splunkforwarder::package_name:
    ensure   => $splunkforwarder::package_ensure,
    source   => $splunkforwarder::source_root,
    provider => 'rpm',
  }
  # enable splunkforwarder
  exec { 'splunkforwarder_license':
    path      => "${splunkforwarder::home_dir}/bin",
    command   => 'splunk start --accept-license --answer-yes --no-prompt',
    creates   => '/opt/splunkforwarder/etc/auth/server.pem',
    timeout   => 0,
    subscribe => Package[$splunkforwarder::package_name],
  }
  # create init file
  exec { 'enable_splunkforwarder':
    path    => "${splunkforwarder::home_dir}/bin",
    command => "splunk enable boot-start -user ${splunkforwarder::user}",
    creates => '/etc/init.d/splunk',
    require => Exec['splunkforwarder_license'],
  }
}
