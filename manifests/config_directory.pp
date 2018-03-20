# config_directory.pp

class mongodb_consistent_backup::config_directory (
  Stdlib::Absolutepath  $config_directory = $::mongodb_consistent_backup::config_directory,
) {
  require '::mongodb_consistent_backup::package'

  file { "$config_directory":
    ensure  => directory,
  }
}

# vim: set ts=2 sw=2 et syn=puppet:
