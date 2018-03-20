# init.pp

class mongodb_consistent_backup (
  Boolean               $manage_package   = $::mongodb_consistent_backup::params::manage_package,
  String                $package_name     = $::mongodb_consistent_backup::params::package_name,
  String                $package_ensure   = $::mongodb_consistent_backup::params::package_ensure,
  Stdlib::Absolutepath  $mcb_path         = $::mongodb_consistent_backup::params::mcb_path,
  Stdlib::Absolutepath  $config_directory = $::mongodb_consistent_backup::params::config_directory,
) inherits ::mongodb_consistent_backup::params {
  contain '::mongodb_consistent_backup::package'
  contain '::mongodb_consistent_backup::config_directory'
}

# vim: set ts=2 sw=2 et syn=puppet:
