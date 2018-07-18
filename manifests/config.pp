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
  # directories
  file {
    $splunkforwarder::home_dir:
      ensure => $splunkforwarder::directory_ensure;
    $splunkforwarder::log_dir:
      ensure  => $splunkforwarder::directory_ensure,
      require => File[$splunkforwarder::home_dir];
  }
  # main config files
  ['inputs.conf', 'outputs.conf', 'web.conf', 'limits.conf'].each |$key| {
    file { "${splunkforwarder::config_dir}/${key}":
      content => template("${module_name}/conf.d/${key}.erb"),
    }
  }
  file {
    "${splunkforwarder::config_dir}/server.conf":
      path  => "${splunkforwarder::config_dir}/server.conf";
    "${splunkforwarder::home_dir}/etc/splunk-launch.conf":
      content => template("${module_name}/conf.d/splunk-launch.conf.erb");
  }
  # log files
  $splunkforwarder::log_files.each |String $files| {
    file{ "${splunkforwarder::log_dir}/${files}.log":
      mode    => $splunkforwarder::log_files_mode,
      require => File[$splunkforwarder::log_dir],
    }
  }
}
