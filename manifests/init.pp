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
  Variant[Enum['present','absent'], Pattern[/^[.+_0-9:~-]+(\-\w+)?$/]] $version,
  String $package_name,
  String $package_source,
  String $package_provider,
  Enum['present','absent'] $config_ensure,
  String $home_dir,
  String $config_dir,
  String $run_dir,
  String $log_dir,
  String $apps_dir,
  Array $log_files,
  String $log_files_mode,
  Enum['running','stopped'] $service_ensure,
  String $server,
  String $local_server,
  String $web_name,
  String $user,
  String $group,
  String $database,
  Boolean $enable_db,
  String $password,
  Hash $applications,
  ){
  # default variables
  $directory_ensure = $config_ensure ? {
    'present' => 'directory',
    default => $splunkforwarder::config_ensure,
  }
  $source_installer = $facts['os']['family'] ? {
    'Debian' => "/tmp/${package_name}-${version}.deb",
    default => $package_source,
  }
  $accept_license = 'accept-license --answer-yes --no-prompt'
  $enable_splunkforwarder_cmd = $version ? {
    /^6[.]/ => "splunk enable boot-start -user ${splunkforwarder::user} --${accept_license}",
    default => "splunk enable boot-start -user ${splunkforwarder::user} --${accept_license} --seed-passwd ${splunkforwarder::password}",
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
