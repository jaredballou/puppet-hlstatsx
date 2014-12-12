# == Class: hlstatsx
#
# Full description of class hlstatsx here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'hlstatsx':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class hlstatsx(
  $source_type = 'git',
  $source_url  = 'git@github.com:jaredballou/insurgency-hlstatsx.git',
  $user        = 'insserver',
  $group       = 'insserver',
  $rootpath    = '/opt/hlstatsx-community-edition',
) {
  require apache
  require mysql
  Vcsrepo { owner => $user, group => $group, ensure => present, provider => git, revision => 'master', }

  exec { 'create-hlstatsx-rootpath': command => "mkdir -p \"${rootpath}\"", creates => $rootpath, } ->
  file { $rootpath: ensure => directory, owner => $user, group => $group, mode => '0775', } ->
  vcsrepo { $rootpath:
    source   => $source_url,
  }

}
