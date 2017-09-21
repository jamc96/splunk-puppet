# == Class splunkforwarder::config
#
# This class is called from splunkforwarder for service config.
#
class splunkforwarder::config(
  String $server       = $::splunkforwarder::server,
  String $port         = $::splunkforwarder::port,
  String $local_server = $::splunkforwarder::local_server,
  String $config_dir   = $::splunkforwarder::config_dir,
  String $owner        = $::splunkforwarder::config_owner,
  String $group        = $::splunkforwarder::config_group,
  ) {
  File {
    ensure => 'present',
    owner  => $owner,
    group  => $group,
  }
  file { 'inputs.conf':
    path    => "${config_dir}/inputs.conf",
    content => template('splunkforwarder/conf.d/inputs.conf.erb');
    'outputs.conf':
    path    => "${config_dir}/outputs.conf",
    content => template('splunkforwarder/conf.d/outputs.conf.erb');
    'server.conf':
    path    => "${config_dir}/server.conf";
    'web.conf':
    path    => "${config_dir}/web.conf",
    content => template('splunkforwarder/conf.d/web.conf.erb');
    'limits.conf':
    path    => "${config_dir}/limits.conf",
    content => template('splunkforwarder/conf.d/limits.conf.erb');
  }
}