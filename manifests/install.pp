# == Class splunkforwarder::install
#
# This class is called from splunkforwarder for install.
#
class splunkforwarder::install inherits splunkforwarder {
  # splunk package
  package { $splunkforwarder::package_name:
    ensure   => $splunkforwarder::package_ensure,
    source   => $splunkforwarder::source_root,
    provider => 'rpm',
  }
  # enable splunkforwarder
  exec { 'splunkforwarder_license':
    path      => "${splunkforwarder::home_dir}/bin",
    command   => 'splunk start --accept-license --answer-yes --no-prompt',
    creates   => '/opt/splunkforwarder/etc/auth/server.pem',
    timeout   => 0,
    subscribe => Package[$splunkforwarder::package_name],
    notify    => Exec['enable_splunkforwarder'],
  }
  # create init file
  exec { 'enable_splunkforwarder':
    path    => "${splunkforwarder::home_dir}/bin",
    command => "splunk enable boot-start -user ${splunkforwarder::user}",
    creates => '/etc/init.d/splunk',
  }
  # add permission to splunk files
  exec { 'splunk_permission':
    command     => "chown -R ${splunkforwarder::user}:${splunkforwarder::group} ${splunkforwarder::home_dir}/*",
    refreshonly => true,
    creates     => $splunkforwarder::home_dir,
    subscribe   => Exec['enable_splunkforwarder'],
    path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }
}
