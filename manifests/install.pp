# == Class splunkforwarder::install
#
# This class is called from splunkforwarder for install.
#
class splunkforwarder::install inherits splunkforwarder {
  # splunk package
  if $splunkforwarder::package_provider == 'dpkg' {
    # download package
    file { $splunkforwarder::package_source:
      ensure => 'file',
      owner  => 0,
      group  => 0,
      mode   => '0644',
      source => $splunkforwarder::source_root,
      notify => Package['splunkforwarder'],
    }
  }
  # install package
  package { 'splunkforwarder':
    ensure   => $splunkforwarder::package_ensure,
    source   => $splunkforwarder::package_source,
    provider => $splunkforwarder::package_provider,
  }
}