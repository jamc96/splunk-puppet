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
}
