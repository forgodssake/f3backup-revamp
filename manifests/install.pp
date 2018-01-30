# @api private
# This class handles f3backup packages. Avoid modifying private classes.
class f3backup::install {

  if $f3backup::package_manage {

    package { $f3backup::package_name:
      ensure => $f3backup::package_ensure,
    }

  }

}
