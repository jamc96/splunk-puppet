# == Class splunkforwarder::install
#
# This class is called from splunkforwarder for install.
#
class splunkforwarder::install(
  $package_name = $::splunkforwarder::package_name,
  $package_source = $::splunkforwarder::source_root,
  ) {

  package { $::splunkforwarder::package_name:
    ensure => present,
    source => $package_source,
  }
}
