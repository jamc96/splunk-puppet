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
      path    => "${splunkforwarder::config_dir}/${key}",
      content => template("${module_name}/conf.d/${key}.erb"),
    }
  }
  file {
    'server.conf':
      path  => "${splunkforwarder::config_dir}/server.conf";
    'splunk-launch.conf':
      path    => "${splunkforwarder::home_dir}/etc/splunk-launch.conf",
      content => template("${module_name}/conf.d/splunk-launch.conf.erb");
  }
  # Log directory
  file { $splunkforwarder::log_dir:
    ensure => directory,
  }
  # log files
  $splunkforwarder::log_files.each |String $files| {
    file{ $files:
      path    => "${splunkforwarder::log_dir}/${files}.log",
      mode    => $splunkforwarder::log_files_mode,
      require => File[$splunkforwarder::log_dir],
    }
  }
  # enable splunkforwarder
  exec { 'splunkforwarder_license':
    path    => "${splunkforwarder::home_dir}/bin",
    command => 'splunk start --accept-license --answer-yes --no-prompt',
    creates => '/opt/splunkforwarder/etc/auth/server.pem',
    timeout => 0,
    require => Class['::splunkforwarder::install'],
  }
  # create init file
  exec { 'enable_splunkforwarder':
    path    => "${splunkforwarder::home_dir}/bin",
    command => "splunk enable boot-start -user ${splunkforwarder::user}",
    creates => '/etc/init.d/splunk',
    require => Exec['splunkforwarder_license'],
  }
}
