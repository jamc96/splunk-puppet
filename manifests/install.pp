# == Class splunkforwarder::install
#
# This class is called from splunkforwarder for install.
#
class splunkforwarder::install inherits splunkforwarder {
  # splunk package
  if $splunkforwarder::package_provider == 'dpkg' {
    # download package
    file { $splunkforwarder::source_installer:
      ensure => 'file',
      owner  => 0,
      group  => 0,
      mode   => '0644',
      source => $splunkforwarder::package_source,
      before => Package['splunkforwarder'],
    }
  }
  # install package
  package { 'splunkforwarder':
    ensure   => $splunkforwarder::version,
    source   => $splunkforwarder::source_installer,
    provider => $splunkforwarder::package_provider,
  }
}
