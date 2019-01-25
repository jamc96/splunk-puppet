# Class: splunkforwarder
# ===========================
#
# Full description of class splunkforwarder here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'splunkforwarder':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class splunkforwarder (
  Variant[Enum['present','absent'], Pattern[/^[.+_0-9:~-]+(\-\w+)?$/]] $version = 'present',
  String $package_name                      = 'splunkforwarder',
  Enum['present','absent'] $config_ensure   = 'present',
  String $home_dir                          = '/opt/splunkforwarder',
  String $config_dir                        = "${home_dir}/etc/system/local",
  String $run_dir                           = "${home_dir}/var/run",
  String $log_dir                           = "${home_dir}/var/log/splunk",
  String $apps_dir                          = "${home_dir}/etc/apps",
  Array $log_files                          = ['audit','btool','conf','splunkd','splunkd_access','mongod','scheduler'],
  String $log_files_mode                    = '0700',
  Enum['running','stopped'] $service_ensure = 'running',
  String $server                            = 'splunkforwarder',
  String $local_server                      = $::hostname,
  String $web_name                          = 'splunkweb',
  String $user                              = 'splunk',
  String $group                             = 'splunk',
  String $database                          = '/home/build/build-home/ivory/var/lib/splunk',
  Boolean $enable_db                        = false,
  String $source_root                       = "/tmp/${package_name}-${version}",
  String $password                          = 'admin',
  Hash $applications                        = {},
  ){
  # default variables
  $directory_ensure = $config_ensure ? {
    'present' => 'directory',
    default => $splunkforwarder::config_ensure,
  }
  case $facts['os']['family'] {
    'Debian': {
      $package_ensure = 'present'
      $package_provider = 'dpkg'
      $package_source = "/tmp/${package_name}-${version}.deb"
    }
    default: {
      $package_ensure = $version
      $package_provider = 'rpm'
      $package_source = $source_root
    }
  }
  # module containment
  contain ::splunkforwarder::install
  contain ::splunkforwarder::config
  contain ::splunkforwarder::service
  # module relationship
  Class['::splunkforwarder::install']
  -> Class['::splunkforwarder::config']
  ~> Class['::splunkforwarder::service']
}
