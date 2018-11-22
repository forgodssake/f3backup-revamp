# Class: f3backup
# ===========================
#
# f3backup client class.
# To be used on all servers that need to be backed up.
# Parameters available to override server defaults.
#
# Parameters
# ----------
#
# General configuration
#
# [*backup_home*]
# String:
# Base folder to put the f3backup folder containing all backups.
#
# [*backup_server*]
# String:
# Backup server that should perform backups on this servers.
# Multiple backup servers can backup the same id so backups are in different physical servers.
# Also you can split backups in different servers by configuring clients & servers with different ids.
#
# [*myname*]
# String:
# Name of the server.
# Must be unique among the backup server.
#
# [*ensure*]
# String:
# Ensure class is present or absent.
# Set to absent in servers to avoid errors while trying to backup himself.
#
# Client parameters that override default backup config
#
# [*backup_rdiff*]
# Boolean:
# Perform rdiff backup.
#
# [*backup_command*]
# Boolean:
# Perform command backup.
#
# [*priority*]
# Integer:
# Priority to perform the backup.
#
# [*rdiff_keep*]
# String:
# Time to keep backups.
#
# [*rdiff_global_exclude_file*]
# String:
# File with globally excluded files.
#
# [*rdiff_user*]
# String:
# User to use when performing the rdiff backups.
#
# [*rdiff_path*]
# String:
# Base path for the rdiff backup.
#
# [*rdiff_extra_parameters*]
# String:
# Extra parameters to pass to the rdiff backup.
#
# [*command_to_execute*]
# String:
# Command to execute when performing the command backup.
#
# Package parameters
#
# [*package_ensure*]
# String:
# Ensure the package is present (installed) or absent (uninstalled).
#
# [*package_manage*]
# String:
# Chooses whether the rdiff-backup package should be managed by puppet.
#
# [*package_name*]
# String:
# Sets the name of the rdiff-backup package.
#
# Examples
# --------
#
#  Simplest case:
#  class { '::f3backup': }
#
#  Backup to non-default server and keep for 6 Months
#  class { '::f3backup':
#    backup_server => 'long-retention',
#    rdiff_keep    => '6M',
#  }

class f3backup (
  $backup_home   = '/backup',
  $backup_server = 'default',
  $myname        = $::fqdn,
  $ensure        = 'present',
  # Client override parameters
  $backup_rdiff = true,
  $backup_command = false,
  $priority = '10',
  $rdiff_keep = '4W',
  $rdiff_global_exclude_file = false,
  $rdiff_user = false,
  $rdiff_path = false,
  $rdiff_extra_parameters = '',
  $command_to_execute = '/bin/true',

  # Package parameters
  String $package_ensure = 'present',
  Boolean $package_manage = true,
  String $package_name = 'rdiff-backup',
) {

  contain f3backup::install
  contain f3backup::config

  Class['::f3backup::install']
  -> Class['::f3backup::config']
}

