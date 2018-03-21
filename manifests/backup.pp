# backup.pp

define mongodb_consistent_backup::backup (
  Stdlib::Absolutepath  $mcb_path         = $::mongodb_consistent_backup::mcb_path,
  Stdlib::Absolutepath  $config_directory = $::mongodb_consistent_backup::config_directory,

  Boolean                                                                                     $manage_cron   = true,
  Optional[Variant[Array[Variant[Integer[0, 59], String]], Variant[Integer[0, 59], String]]]  $cron_minute   = undef,
  Optional[Variant[Array[Variant[Integer[0, 23], String]], Variant[Integer[0, 23], String]]]  $cron_hour     = undef,
  Optional[Variant[Array[Variant[Integer[0, 7], String]], Variant[Integer[0, 7], String]]]    $cron_weekday  = undef,
  Optional[Variant[Array[Variant[Integer[1, 31], String]], Variant[Integer[1, 31], String]]]  $cron_monthday = undef,
  Optional[Variant[Array[Variant[Integer[1, 12], String]], Variant[Integer[1, 12], String]]]  $cron_month    = undef,
  Optional[String]                                                                            $cron_special  = undef,
  Optional[String]                                                                            $cron_user     = undef,
  Optional[Stdlib::Absolutepath]                                                              $cron_target   = undef,
  Optional[String]                                                                            $cron_provider = undef,

  Boolean                                         $verbose                        = false,
  Enum['production', 'staging', 'development']    $environment                    = 'production',
  String                                          $host                           = 'localhost',
  Integer[1, 65535]                               $port                           = 27017,
  Optional[String]                                $username                       = undef,
  Optional[String]                                $password                       = undef,
  String                                          $authdb                         = 'admin',
  Boolean                                         $ssl_enabled                    = false,
  Boolean                                         $ssl_insecure                   = false,
  Optional[Stdlib::Absolutepath]                  $ssl_ca_file                    = undef,
  Optional[Stdlib::Absolutepath]                  $ssl_crl_file                   = undef,
  Optional[Stdlib::Absolutepath]                  $ssl_client_cert_file           = undef,
  Variant[Stdlib::Absolutepath, Pattern[/\A\Z/]]  $log_dir                        = '',
  Stdlib::Absolutepath                            $lock_file                      = '/tmp/mongodb-consistent-backup.lock',
  Integer[0]                                      $rotate_max_backups             = 0,
  Float[0.0]                                      $rotate_max_days                = 0.0,
  Integer[1]                                      $sharding_blancer_wait_secs     = 300,
  Integer[1]                                      $sharding_blancer_ping_secs     = 3,
  Enum['tar', 'zbackup', 'none']                  $archive_method                 = 'tar',
  Enum['gzip', 'none']                            $archive_tar_compression        = 'gzip',
  Integer[0]                                      $archive_tar_threads            = 0,
  Stdlib::Absolutepath                            $archive_zbackup_binary         = '/usr/bin/zbackup',
  Integer[1]                                      $archive_zbackup_cache_mb       = 128,
  Enum['lzma']                                    $archive_zbackup_compression    = 'lzma',
  Optional[Stdlib::Absolutepath]                  $archive_zbackup_password_file  = undef,
  Integer[0]                                      $archive_zbackup_threads        = 0,
  String                                          $backup_name                    = $name,
  Stdlib::Absolutepath                            $backup_location                = '/var/lib/mongodb-consistent-backup',
  Enum['mongodump']                               $backup_method                  = 'mongodump',
  Stdlib::Absolutepath                            $backup_mongodump_binary        = '/usr/bin/mongodump',
  Enum['auto', 'none', 'gzip']                    $backup_mongodump_compression   = 'auto',
  Integer[0]                                      $backup_mongodump_threads       = 0,
  Enum['nsca', 'none']                            $notify_method                  = 'none',
  Optional[String]                                $notify_nsca_server             = undef,
  Optional[String]                                $notify_nsca_password           = undef,
  Optional[String]                                $notify_nsca_check_name         = undef,
  Optional[String]                                $notify_nsca_check_host         = undef,
  Enum['none', 'gzip']                            $oplog_compression              = 'none',
  Integer[1]                                      $oplog_flush_max_docs           = 100,
  Integer[1]                                      $oplog_flush_max_secs           = 1,
  Integer[0]                                      $oplog_resolver_threads         = 0,
  Variant[Boolean, String]                        $oplog_tailer_enabled           = 'true',
  Integer[1]                                      $oplog_tailer_status_interval   = 30,
  Integer[1]                                      $replication_max_lag_secs       = 10,
  Integer[0]                                      $replication_min_priority       = 0,
  Integer[0]                                      $replication_max_priority       = 1000,
  Boolean                                         $replication_hidden_only        = false,
  Optional[Hash[String, Any]]                     $replication_read_pref_tags     = undef,
  Enum['gs', 'rsync', 's3', 'none']               $upload_method                  = 'none',
  Boolean                                         $upload_remove_uploaded         = false,
  Integer[0]                                      $upload_retries                 = 5,
  Integer[1]                                      $upload_threads                 = 4,
  Optional[String]                                $upload_gs_project_id           = undef,
  Optional[String]                                $upload_gs_access_key           = undef,
  Optional[String]                                $upload_gs_secret_key           = undef,
  Optional[String]                                $upload_gs_bucket_name          = undef,
  Optional[String]                                $upload_gs_bucket_prefix        = undef,
  Stdlib::Absolutepath                            $upload_rsync_path              = '/',
  Optional[String]                                $upload_rsync_user              = undef,
  Optional[String]                                $upload_rsync_host              = undef,
  Integer[1, 65535]                               $upload_rsync_port              = 22,
  Optional[Stdlib::Absolutepath]                  $upload_rsync_ssh_key           = undef,
  String                                          $upload_s3_region               = 'us-east-1',
  Optional[String]                                $upload_s3_access_key           = undef,
  Optional[String]                                $upload_s3_secret_key           = undef,
  Optional[String]                                $upload_s3_bucket_name          = undef,
  Optional[String]                                $upload_s3_bucket_prefix        = undef,
  Optional[String]                                $upload_s3_bucket_explicit_key  = undef,
  Integer[1]                                      $upload_s3_chunk_size_mb        = 50,
  Boolean                                         $upload_s3_secure               = true,
  Optional[String]                                $upload_s3_acl                  = undef,
) {
  require '::mongodb_consistent_backup::package'
  require '::mongodb_consistent_backup::config_directory'

  $path = "$config_directory/$title.yaml"
  file { "$path":
    ensure  => file,
    content => epp("$module_name/mongodb-consistent-backup.yaml.eep", {
      backup  => Mongodb_consistent_backup::Backup[$title],
      path    => $path,
    }),
  }

  if $manage_cron {
    $verbose_option = $verbose ? {
      true: '--verbose',
      default: '',
    }

    cron { "mongodb-consistent-backup-$title":
      command   => "'$mcb_path' $verbose_option --config '$path'"
      minute    => $cron_minute,
      hour      => $cron_hour,
      weekday   => $cron_weekday,
      monthday  => $cron_monthday,
      month     => $cron_month,
      special   => $cron_special,
      user      => $cron_user,
      target    => $cron_target,
      provider  => $cron_provider
      require   => File[$path],
    }
  }
}

# vim: set ts=2 sw=2 et syn=puppet:
