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
  String $package_name        = $splunkforwarder::params::package_name,
  String $package_ensure      = $splunkforwarder::params::package_ensure,
  String $package_provider    = $splunkforwarder::params::package_provider,
  String $source_root         = $splunkforwarder::params::source_root,
  String $user                = $splunkforwarder::params::user,
  String $port                = $splunkforwarder::params::port,
  String $server              = $splunkforwarder::params::server,
  String $version             = $splunkforwarder::params::version,
  String $local_server        = $splunkforwarder::params::local_server,
  String $home_dir            = $splunkforwarder::params::home_dir,
  String $config_dir          = $splunkforwarder::params::config_dir,
  String $run_dir             = $splunkforwarder::params::run_dir,
  String $pid_selinux         = $splunkforwarder::params::pid_selinux,
  String $config_ensure       = $splunkforwarder::params::config_ensure,
  String $config_owner        = $splunkforwarder::params::config_owner,
  String $config_group        = $splunkforwarder::params::config_group,
  String $service_name        = $splunkforwarder::params::service_name,
  String $service_ensure      = $splunkforwarder::params::service_ensure,
  Boolean $service_enable     = $splunkforwarder::params::service_enable,
  Boolean $service_hasstatus  = $splunkforwarder::params::service_hasstatus,
  Boolean $service_hasrestart = $splunkforwarder::params::service_hasrestart,
  String $web_name            = $splunkforwarder::params::web_name,
  String $database            = $splunkforwarder::params::database,
  Boolean $enable_db          = $splunkforwarder::params::enable_db,
  ) inherits splunkforwarder::params {

  contain splunkforwarder::install
  contain splunkforwarder::config
  contain splunkforwarder::service

  class { '::splunkforwarder::install': } ->
  class { '::splunkforwarder::config': } ~>
  class { '::splunkforwarder::service': } ->
  Class['::splunkforwarder']
}
