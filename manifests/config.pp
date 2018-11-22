# Class: f3backup::config
# ===========================
#
# private class to be included by init
#

class f3backup::config {

  if $f3backup::ensure != 'absent' {
    @@concat { "${f3backup::backup_home}/f3backup/${f3backup::myname}/exclude.txt":
      owner          => 'backup',
      group          => 'backup',
      mode           => '0644',
      force          => true,
      ensure_newline => true,
      tag            => "f3backup-${f3backup::backup_server}",
    }

    @@file { "${f3backup::backup_home}/f3backup/${f3backup::myname}":
      ensure => 'directory',
      owner  => 'backup',
      group  => 'backup',
      mode   => '0644',
      tag    => "f3backup-${f3backup::backup_server}",
    }

    @@file { "${f3backup::backup_home}/f3backup/${f3backup::myname}/config.ini":
      content => template('f3backup/f3backup-host.ini.erb'),
      owner   => 'backup',
      group   => 'backup',
      mode    => '0644',
      tag     => "f3backup-${f3backup::backup_server}",
    }

    # Collect the ssh key that the servers exported
    Ssh_authorized_key <<| tag == "f3backup-sshkey-${f3backup::backup_server}" |>>

  } else  {
    # Absent not enforced so it's better to keep the config and exclude files
    @@file { "${f3backup::backup_home}/f3backup/${f3backup::myname}":
      ensure => absent,
    }

  }
}
