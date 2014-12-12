# == Define: hlstatsx::server
#
# Adds a server to HLStatsX
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
#   Explanation of how this variable affects the funtion of this define and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of define parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  hlstatsx::server { 'server.domain.com':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Jared Ballou <puppet@jballou.com>
#
# === Copyright
#
# Copyright 2014 Jared Ballou, unless otherwise noted.
#
define hlstatsx::server(
  $ipaddress     = '127.0.0.1',
  $port          = 27015,
  $servername    = $title,
  $rconpass      = 'Password#1',
  $publicaddress = $::fqdn,
  $game          = 'Insurgency',
  $sortorder     = 0,
  $statusurl     = '',
) {
}
