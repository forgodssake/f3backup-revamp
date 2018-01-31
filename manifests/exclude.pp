define f3backup::exclude {
  include '::f3backup'

  # Get values from init class instead of refedining them to avoid discrepances
  if $::f3backup::ensure != 'absent' {
    @@concat::fragment { "${::f3backup::myname}-${name}":
      target  => "${::f3backup::backup_home}/f3backup/${::f3backup::myname}/exclude.txt",
      content => $name,
      tag     => "f3backup-${::f3backup::backup_server}",
    }
  }
}
