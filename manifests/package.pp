# package.pp

class mongodb_consistent_backup::package (
  Boolean $manage_package = $::mongodb_consistent_backup::manage_package,
  String  $package_name   = $::mongodb_consistent_backup::package_name,
  String  $package_ensure = $::mongodb_consistent_backup::package_ensure,
) {
  if $manage_package {
    package { 'mongodb-consistent-backup':
      name    => $package_name,
      ensure  => $package_ensure,
    }
  }
}

# vim: set ts=2 sw=2 et syn=puppet:
