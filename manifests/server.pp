class f3backup::server (
  # Name for the client resources to realize
  Array[String] $backup_server      = [ 'default' ],
  # Home directory of the backup user
  String $backup_home               = '/backup',
  # Ssh Key
  Optional[String] $source_ssh_key  = undef,
  Optional[String] $source_ssh_pub  = undef,
  # Main f3backup.ini options
  Integer $threads                  = 5,
  String $lognameprefix             = '%Y%m%d-',
  String $rdiff_global_exclude_file = '/etc/f3backup-exclude.txt, /backup/f3backup/%server%/exclude.txt',
  String $rdiff_user                = 'root',
  String $rdiff_path                = '/',
  String $rdiff_extra_parameters    = '',
  String $command_to_execute        = '/bin/true',
  # Cron job options
  String $cron_hour                 = '03',
  String $cron_minute               = '00',
  String $cron_weekday              = '*',
  String $cron_mailto               = 'root',
  # ssh config entries
  Array[String] $ssh_config         = [ '' ],
  Hash $ssh_config_hosts            = {},
) {

  # TODO:
  # Virtual resource for the ssh key to be realized on nodes to be backed up
  # command="rdiff-backup --server --restrict-read-only /",from="${backserver}",no-port-forwarding,no-agent-forwarding,no-X11-forwarding,no-pty

  $backup_server.each |$server| {
    # Virtual resources created by backup clients
    File <<| tag == "f3backup-${server}" |>>
    Concat <<| tag == "f3backup-${server}" |>>
    Concat::Fragment <<| tag == "f3backup-${server}" |>>
  }

  # Useful to save space across backups of identical OSes
  package { 'hardlink': ensure => 'installed' }

  # Create user backup, who will connect to the clients
  user { 'backup':
    comment    => 'Backup',
    shell      => '/bin/bash',
    home       => $backup_home,
    managehome => true,
  }
  file { "${backup_home}/f3backup":
    ensure  => 'directory',
    owner   => 'backup',
    group   => 'backup',
    mode    => '0700',
    require => User['backup'];
  }
  file { '/var/log/f3backup':
    ensure  => 'directory',
    owner   => 'backup',
    group   => 'backup',
    mode    => '0700',
    require => User['backup'];
  }

  # Create directory where the ssh key pair will be stored
  file { "${backup_home}/.ssh":
    ensure  => 'directory',
    owner   => 'backup',
    group   => 'backup',
    mode    => '0700',
    require => User['backup'];
  }
  # Make ssh connections "relaxed" so that things work automatically
  file { "${backup_home}/.ssh/config":
    content => template("${module_name}/ssh-config.erb"),
    owner   => 'backup',
    group   => 'backup',
    mode    => '0600',
    require => User['backup'];
  }

  # Check if the ssh key is being provided
  if $source_ssh_key and $source_ssh_pub {
    file { "${backup_home}/.ssh/id_rsa":
      owner   => 'backup',
      group   => 'backup',
      mode    => '0600',
      source  => $source_ssh_key,
      require => File["${backup_home}/.ssh"],
    }
    file { "${backup_home}/.ssh/id_rsa.pub":
      owner   => 'backup',
      group   => 'backup',
      mode    => '0600',
      source  => $source_ssh_pub,
      require => File["${backup_home}/.ssh"],
    }
  # no xor in puppet so we'll count how many non-undef values we have and fail if it's 1
  } elsif count([$source_ssh_key,$source_ssh_pub]) == 1 {
    fail("Please setup both \$source_ssh_key and \$source_ssh_pub or none, but not just one.")
  } else {
    # Otherwise, create it
    exec { 'Creating key pair for user backup':
      command => "/usr/bin/ssh-keygen -b 2048 -t rsa -f ${backup_home}/.ssh/id_rsa -N ''",
      user    => 'backup',
      group   => 'backup',
      require => [
        User['backup'],
        File["${backup_home}/.ssh"],
      ],
      creates => "${backup_home}/.ssh/id_rsa",
    }
  }

  if versioncmp($::operatingsystemrelease, '7') >= 0 {
    $package_paramiko = 'python2-paramiko'
  }  else {
    $package_paramiko = 'python-paramiko'
  }

  # The main backup script
  package { $package_paramiko: ensure => installed }
  file { '/usr/local/bin/f3backup':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => "puppet:///modules/${module_name}/f3backup",
    require => Package[$package_paramiko],
  }

  # The main configuration and exclude files
  file { '/etc/f3backup.ini':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/f3backup.ini.erb"),
  }
  file { '/etc/f3backup-exclude.txt':
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => "puppet:///modules/${module_name}/f3backup-exclude.txt",
  }

  # The cron job to start it all
  cron { 'f3backup':
    command     => '/usr/local/bin/f3backup /etc/f3backup.ini',
    user        => 'backup',
    hour        => $cron_hour,
    minute      => $cron_minute,
    weekday     => $cron_weekday,
    environment => [ "MAILTO=${cron_mailto}" ],
    require     => [
      User['backup'],
      File['/usr/local/bin/f3backup'],
    ],
  }

}
