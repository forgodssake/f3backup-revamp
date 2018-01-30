class f3backup::server::install {


  # Useful to save space across backups of identical OSes
  package { 'hardlink': ensure => 'installed' }

  if versioncmp($::operatingsystemrelease, '7') >= 0 {
    $package_paramiko = 'python2-paramiko'
  }  else {
    $package_paramiko = 'python-paramiko'
  }

  # The main backup script
  package { $package_paramiko: ensure => installed }
}
