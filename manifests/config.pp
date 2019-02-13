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
  Exec {
    refreshonly => true,
  }
  # main directories
  [$splunkforwarder::home_dir, $splunkforwarder::apps_dir].each |$dir| {
    file { $dir:
      ensure => $splunkforwarder::directory_ensure;
    }
  }
  # configuration files
  file {
    "${splunkforwarder::config_dir}/server.conf":
      path  => "${splunkforwarder::config_dir}/server.conf";
    "${splunkforwarder::home_dir}/etc/splunk-launch.conf":
      content => template("${module_name}/conf.d/splunk-launch.conf.erb"),
      notify  => Exec['enable_splunkforwarder'];
  }
  # accept license terms and create directories
  $accept_license = 'accept-license --answer-yes --no-prompt'
  exec { 'enable_splunkforwarder':
    path    => "${splunkforwarder::home_dir}/bin",
    command => "splunk enable boot-start -user ${splunkforwarder::user} --${accept_license} --seed-passwd ${splunkforwarder::password}",
    returns => [0,8],
  }
  # execute only when upgrade
  $change_splunk_password = "runuser -l splunk -c '${splunkforwarder::home_dir}/bin/splunk edit user admin"
  exec { 'set_splunk_password':
    path      => '/usr/bin:/usr/sbin:/bin:/sbin',
    command   => "${change_splunk_password} -password ${splunkforwarder::password} -auth admin:changeme'",
    subscribe => Package[$splunkforwarder::package_name],
    after     => Exec['enable_splunkforwarder'],
  }
  # log dir
  file {
    $splunkforwarder::config_dir:
      ensure  => $splunkforwarder::directory_ensure,
      require => Exec['enable_splunkforwarder'];
    $splunkforwarder::log_dir:
      ensure  => $splunkforwarder::directory_ensure,
      require => Exec['enable_splunkforwarder'],
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
  # application settings
  $splunkforwarder::applications.each |$app, $configs| {
    splunkforwarder::app { $app:
      path    => $splunkforwarder::apps_dir,
      *       => $configs,
      require => File[$splunkforwarder::apps_dir],
    }
  }
}
