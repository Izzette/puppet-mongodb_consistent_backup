# params.pp

class mongodb_consistent_backup::params {
  $manage_package   = false
  $package_name     = 'mongodb-consistent-backup'
  $package_ensure   = 'installed'
  $mcb_path         = '/usr/bin/mongodb-consistent-backup'
  $config_directory = '/etc/mongodb-consistent-backup.d'
}

# vim: set ts=2 sw=2 et syn=puppet:
