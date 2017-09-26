# == Class splunkforwarder::install
#
# This class is called from splunkforwarder for install.
#
class splunkforwarder::install(
  $package_name     = $::splunkforwarder::package_name,
  $package_ensure   = $::splunkforwarder::package_ensure,
  $package_source   = $::splunkforwarder::source_root,
  $package_provider = $::splunkforwarder::package_provider,
  ) {

  package { $package_name:
    ensure   => $package_ensure,
    source   => $package_source,
    provider => $package_provider,
  }
}
