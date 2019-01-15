# == Class splunkforwarder::config
#
# This class is called from splunkforwarder for service config.
#
class splunkforwarder::config inherits splunkforwarder {
  # defaults
  File {
    ensure                  => $splunkforwarder::config_ensure,
    owner                   => $splunkforwarder::user,
    group                   => $splunkforwarder::group,
    selinux_ignore_defaults => true,
  }
  # main directory
  file {  $splunkforwarder::home_dir:
      ensure => $splunkforwarder::directory_ensure,
  }
  file {
    "${splunkforwarder::config_dir}/server.conf":
      path  => "${splunkforwarder::config_dir}/server.conf";
    "${splunkforwarder::home_dir}/etc/splunk-launch.conf":
      content => template("${module_name}/conf.d/splunk-launch.conf.erb");
  }
  # accept license terms and create directories
  exec { 'splunkforwarder_license':
    path      => "${splunkforwarder::home_dir}/bin",
    command   => "splunk start --accept-license --answer-yes --no-prompt --seed-passwd ${splunkforwarder::password}",
    creates   => '/opt/splunkforwarder/etc/auth/server.pem',
    timeout   => 0,
    subscribe => Package[$splunkforwarder::package_name],
    require   => File["${splunkforwarder::home_dir}/etc/splunk-launch.conf"],
    notify    => Exec['enable_splunkforwarder'],
  }
  # create init file
  exec { 'enable_splunkforwarder':
    path    => "${splunkforwarder::home_dir}/bin",
    command => "splunk enable boot-start -user ${splunkforwarder::user}",
    creates => '/etc/init.d/splunk',
  }
  # log dir
  file {
    $splunkforwarder::config_dir:
      ensure  => $splunkforwarder::directory_ensure,
      require => Exec['splunkforwarder_license'];
    $splunkforwarder::log_dir:
      ensure  => $splunkforwarder::directory_ensure,
      require => Exec['splunkforwarder_license'],
  }
  # main config files
  ['inputs.conf', 'outputs.conf', 'web.conf', 'limits.conf'].each |$key| {
    file { "${splunkforwarder::config_dir}/${key}":
      content => template("${module_name}/conf.d/${key}.erb"),
      require => File[$splunkforwarder::config_dir],
    }
  }
  # log files
  $splunkforwarder::log_files.each |String $files| {
    file{ "${splunkforwarder::log_dir}/${files}.log":
      mode    => $splunkforwarder::log_files_mode,
      require => File[$splunkforwarder::log_dir],
    }
  }
}
