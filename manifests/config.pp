# == Class splunkforwarder::config
#
# This class is called from splunkforwarder for service config.
#
class splunkforwarder::config(
  String $splunk_user  = $::splunkforwarder::user,
  String $server       = $::splunkforwarder::server,
  String $port         = $::splunkforwarder::port,
  String $local_server = $::splunkforwarder::local_server,
  String $config_dir   = $::splunkforwarder::config_dir,
  String $ensure       = $::splunkforwarder::config_ensure,
  String $owner        = $::splunkforwarder::config_owner,
  String $group        = $::splunkforwarder::config_group,
  String $home_dir     = $::splunkforwarder::home_dir,
  String $user         = $::splunkforwarder::user,
  String $version      = $::splunkforwarder::version,
  String $web_name     = $::splunkforwarder::web_name,
  String $database     = $::splunkforwarder::database,
  Boolean $enable_db   = $::splunkforwarder::enable_db,
  ) {
  File {
    ensure => $ensure,
    owner  => $owner,
    group  => $group,
  }
  file { 'inputs.conf':
    path    => "${config_dir}/inputs.conf",
    content => template("${module_name}/conf.d/inputs.conf.erb");
    'outputs.conf':
    path    => "${config_dir}/outputs.conf",
    content => template("${module_name}/conf.d/outputs.conf.erb");
    'server.conf':
    path    => "${config_dir}/server.conf";
    'web.conf':
    path    => "${config_dir}/web.conf",
    content => template("${module_name}/conf.d/web.conf.erb");
    'limits.conf':
    path    => "${config_dir}/limits.conf",
    content => template("${module_name}/conf.d/limits.conf.erb");
    'splunk-launch.conf':
    path    => "${home_dir}/etc/splunk-launch.conf",
    content => template("${module_name}/conf.d/splunk-launch.conf.erb");
  }
  # Enable splunkforwarder
  exec { 'splunkforwarder_license':
    path    => "${home_dir}/bin",
    command => 'splunk start --accept-license --answer-yes --no-prompt',
    creates => '/opt/splunkforwarder/etc/auth/server.pem',
    timeout => 0,
    require => Class['::splunkforwarder::install'],
  }
  # Creating the splunk service init file
  exec { 'enable_splunkforwarder':
    path    => "${home_dir}/bin",
    command => "splunk enable boot-start -user ${splunk_user}",
    creates => '/etc/init.d/splunk',
    require => Exec['splunkforwarder_license'],
  }
}
