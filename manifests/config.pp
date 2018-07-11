# == Class splunkforwarder::config
#
# This class is called from splunkforwarder for service config.
#
class splunkforwarder::config inherits splunkforwarder {
  # defaults
  File {
    ensure                  => $splunkforwarder::config_ensure,
    owner                   => 'splunk',
    group                   => 'splunk',
    selinux_ignore_defaults => true,
  }
  # main config files
  ['inputs.conf', 'outputs.conf', 'web.conf', 'limits.conf'].each |$key| {
    file { $key:
      path => "${config_dir}/${key}",
      content => template("${module_name}/conf.d/${key}.erb")
    }
  }
  file {
    'server.conf':
      path    => "${config_dir}/server.conf";
    'splunk-launch.conf':
      path    => "${home_dir}/etc/splunk-launch.conf",
      content => template("${module_name}/conf.d/splunk-launch.conf.erb");
  }
  # Log directory
  file { $splunkforwarder::log_dir: 
    ensure => directory,
  }
  # log files
  ['audit','btool','conf','splunkd','splunkd_access','mongod','scheduler'].each |String $files| {
    file{ $files:
      path => "${log_dir}/${files}.log",
      mode => '0775',
      require => File[$log_dir],
    }
  }
  # enable splunkforwarder
  exec { 'splunkforwarder_license':
    path    => "${home_dir}/bin",
    command => 'splunk start --accept-license --answer-yes --no-prompt',
    creates => '/opt/splunkforwarder/etc/auth/server.pem',
    timeout => 0,
    require => Class['::splunkforwarder::install'],
  }
  # create init file
  exec { 'enable_splunkforwarder':
    path    => "${home_dir}/bin",
    command => "splunk enable boot-start -user ${user}",
    creates => '/etc/init.d/splunk',
    require => Exec['splunkforwarder_license'],
  }
}
