# Class: f3backup
# ===========================
#
# Full description of class f3backup here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'f3backup':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2018 Your name here, unless otherwise noted.
#
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
  String $package_ensure,
  Boolean $package_manage,
  Array[String] $package_name,
) {

  contain f3backup::install
  contain f3backup::config

  Class['::f3backup::install'] ->
  Class['::f3backup::config'] ~>
}

