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
  Optional[Hash] $configurations   = undef,
  Optional[Hash] $deploymentclient = undef,
  Optional[Hash] $localmeta        = undef,
) {
  File {
    ensure => 'present',
    owner  => $user,
    group  => $group,
    mode   => '0600',
  }
  # concat path
  $application_path = "${path}/${name}"
  # creating default directories
  [$application_path, "${application_path}/local", "${application_path}/metadata"].each |$dir| {
    file { $dir:
      ensure => 'directory',
      mode   => '0700',
    }
  }
  # setting up configurations
  # app.conf settings
  if $configurations {
    file { "${application_path}/local/app.conf":
      content => template("${module_name}/conf.d/app.conf.erb"),
      require => File["${application_path}/local"],
    }
  }
  # deploymentclient.conf settings
  if $deploymentclient {
    file { "${application_path}/local/deploymentclient.conf":
      content => template("${module_name}/conf.d/deploymentclient.conf.erb"),
      require => File["${application_path}/local"],
    }
  }
  # local.meta settings
  if $localmeta {
    file { "${application_path}/metadata/local.meta":
      content => template("${module_name}/conf.d/local.meta.erb"),
      require => File["${application_path}/metadata"],
    }
  }
}
