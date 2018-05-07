# == Class splunkforwarder::config
#
# This class is called from splunkforwarder for service config.
#
class splunkforwarder::config(
  $splunk_user   = $::splunkforwarder::user,
  $server        = $::splunkforwarder::server,
  $port          = $::splunkforwarder::port,
  $local_server  = $::splunkforwarder::local_server,
  $config_dir    = $::splunkforwarder::config_dir,
  $config_ensure = $::splunkforwarder::config_ensure,
  $home_dir      = $::splunkforwarder::home_dir,
  $user          = $::splunkforwarder::user,
  $version       = $::splunkforwarder::version,
  $web_name      = $::splunkforwarder::web_name,
  $database      = $::splunkforwarder::database,
  $enable_db    = $::splunkforwarder::enable_db,
  $log_dir       = $::splunkforwarder::log_dir,
  $log_files     = $::splunkforwarder::log_files,
  ) {
  File {
    ensure                  => $config_ensure,
    owner                   => 'splunk',
    group                   => 'splunk',
    selinux_ignore_defaults => true,
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
  # Permissions for log files 
  $log_files.each |String $files|{
    file{ $files:
      path => "${log_dir}/${files}.log",
      mode => '0775',
    }
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
