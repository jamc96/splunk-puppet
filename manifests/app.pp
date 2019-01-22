# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   splunkforwarder::app { 'namevar': }
define splunkforwarder::app(
  String $path,
  Optional[Pattern[/^(puppet\:|https?\:|\/)/]] $source = undef,
  Enum['present','absent'] $ensure = 'present',
  String $user  = 'splunk',
  String $group = 'splunk',
) {
  if $source {
    # get the name of the source. Last element of string
    $source_name =  $source.split('/')[-1]
    # decompress file
    archive { $source_name:
      ensure       => $ensure,
      path         => "${path}/${source_name}",
      source       => $source,
      extract      => true,
      extract_path => $path,
      cleanup      => false,
      user         => $user,
      group        => $group,
      require      => File[$path],
    }
  }
}
