# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   splunkforwarder::app { 'namevar': }
define splunkforwarder::app(
  String $path,
  Enum['present','absent'] $ensure = 'present',
  String $user                     = 'splunk',
  String $group                    = 'splunk',
  Hash $configurations             = {},
  Hash $deploymentclient           = {},
  Hash $localmeta                  = {},
) {
  File {
    ensure => 'present',
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }
  # concat path
  $application_path = "${path}/${name}"
  # creating default directories
  [$application_path, "${application_path}/local", "${application_path}/metadata"].each |$dir| {
    file { $dir:
      ensure => 'directory',
    }
  }
  # setting up configurations
  # app.conf settings
  create_ini_settings($configurations, { 'path' => "${application_path}/local/app.conf" } )
  # deploymentclient.conf settings
  create_ini_settings($deploymentclient, { 'path' => "${application_path}/local/deploymentclient.conf" } )
  # local.meta settings
  create_ini_settings($localmeta, { 'path' => "${application_path}/metadata/local.meta" } )
}
