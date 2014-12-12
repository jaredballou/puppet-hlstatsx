# == Class: hlstatsx
#
# Install and configure HLStatsX, manages users, servers, and games
#
# === Parameters
#
# Document parameters here.
#
# [*source_type*]
#   Method to use to access install media.
#   Default: git
# [*source_url*]
#   URL to use for install files.
#   Default: git@github.com:jaredballou/insurgency-hlstatsx.git
# [*user*]
#   HLStatsX daemon username
#   Default: insserver
# [*group*]
#   Group of HLStatsX daemon user
#   Default: insserver
# [*rootpath*]
#   Root path to install HLStatsX into
#   Default: /opt/hlstatsx-community-edition
# [*db_host*]
#   Database server
#   Default: localhost
# [*db_user*]
#   Database username
#   Default: hlstatsx
# [*db_pass*]
#   Database user password
#   Default: hlstatsx
# [*db_name*]
#   Database name
#   Default: hlstatsx
# [*db_type*]
#   Database type (only MySQL supported)
#   Default: mysql
# [*db_prefix*]
#   Database table name prefix
#   Default: hlstats
# [*bindip*]
#   Bind to a specific IP. Default will bind to all interfaces.
#   Default: 
# [*port*]
#   Port for HLStatsX daemon
#   Default: 27500
# [*debuglevel*]
#   Debug level for HLStatsX daemon
#   Default: 1
# [*web_proto*]
#   Protocol, http or https
#   Default: http
# [*web_server*]
#   Web server, should be the publically resolvable name
#   Default: $::fqdn
# [*web_port*]
#   Port to run on
#   Default: 80
# [*web_path*]
#   Path to append at the end of the URI. Used if HLStatsX is a subdirectory
#   of another vhost. Not yet implemented.
#   Default: 
# [*admin_user*]
#   Admin username
#   Default: admin
# [*admin_pass*]
#   Admin user password
#   Default: Password#1
# [*admin_update*]
#   Always update admin user password to the admin_pass.
#   Default: false
#
# === Variables
#
# [*url*]
#   Assembled from web_ variables to give the URL that should be given to
#   clients to connect to in their browsers.
#
# === Examples
#
#  class { 'hlstatsx':
#    admin_pass => 'Password#1',
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
class hlstatsx(
  $source_type  = 'git',
  $source_url   = 'git@github.com:jaredballou/insurgency-hlstatsx.git',
  $user         = 'insserver',
  $group        = 'insserver',
  $rootpath     = '/opt/hlstatsx-community-edition',
  $db_host      = 'localhost',
  $db_user      = 'hlstatsx',
  $db_pass      = 'hlstatsx',
  $db_name      = 'hlstatsx',
  $db_type      = 'mysql',
  $db_prefix    = 'hlstats',
  $bindip       = '',
  $port         = 27500,
  $debuglevel   = 1,
  $web_proto    = 'http',
  $web_server   = $::fqdn,
  $web_port     = '',
  $web_path     = '',
  $admin_user   = 'admin',
  $admin_pass   = 'Password#1',
  $admin_update = false,
) {
  #Install MySQL if needed
  if ($db_host == 'localhost') {
    include mysql::server
  }
  #Include Apache, mod_php and php-mysql
  include apache
  include apache::mod::php
  include mysql::bindings::php
  #Set defaults for resources
  Vcsrepo { owner => $user, group => $group, ensure => present, provider => git, revision => 'master', }
  File { owner => $user, group => $group, }

  #Assemble the complete URL, only append the port if it's non-standard
  if ($web_port and (($web_port != 80 and $web_proto == 'http') or ($web_port != 443 and $web_proto == 'https'))) {
    $url = "${web_proto}://${web_server}:${web_port}/${web_path}"
    Apache::Vhost { port => $web_port, }
    $web_real_port = $web_port
  } else {
    $url = "${web_proto}://${web_server}/${web_path}"
    $web_real_port = $web_proto ? { 'https' => 443, default => 80, }
  }
  #Install needed packages. TODO: Include other classes to avoid resource collisions
  package { ['git','gdb','mailx','wget','nano','tmux','glibc.i686','libstdc++.i686']: ensure => present, } ->
  #Hack to create install directory with parents if needed
  exec { 'create-hlstatsx-rootpath': command => "mkdir -p \"${rootpath}\"", creates => $rootpath,  } ->
  #Actual file resource for install directory
  file { $rootpath: ensure => directory, mode => '0775', } ->
  #Apache vhost
  apache::vhost { $web_server:
    docroot       => "${rootpath}/web",
    docroot_group => $group,
    docroot_owner => $user,
  } ->
  #Firewall rule for Apache
  firewall { '100 allow http access':
    port   => $web_real_port,
    proto  => tcp,
    action => accept,
  } ->
  #Deploy from Git. This is currently the only supported method
  vcsrepo { $rootpath:
    source   => $source_url,
  } ->
  #Update install.sql dump with any changes (currently just admin password)
  file { "${rootpath}/sql/install.sql": content => template('hlstatsx/install.sql.erb'), } ->
  #Create database, user, and grants as needed, if database does not exist the SQL dump will be imported
  mysql::db { $db_name:
    user           => $db_user,
    password       => $db_pass,
    host           => $db_host,
    grant          => 'ALL',
    sql            => "${rootpath}/sql/install.sql",
  } ->
  #Heatmap config file
  file { "${rootpath}/heatmaps/config.inc.php": content => template('hlstatsx/config.inc.php.erb'), } ->
  #Web UI config file
  file { "${rootpath}/web/config.php": content => template('hlstatsx/config.php.erb'), } ->
  #Daemon config file
  file { "${rootpath}/scripts/hlstats.conf": content => template('hlstatsx/hlstats.conf.erb'), } ->
  #Restart daemon if the config file changes
  exec { 'start-hlstatsx': command => "cd ${rootpath}/scripts/ && ./run_hlstats restart >/dev/null 2>&1", subscribe => File["${rootpath}/scripts/hlstats.conf"], refreshonly => true, user => $user, } ->
  #Cron job to check and start daemon every 5 minutes
  cron { 'run-hlstats': minute => '*/5', command => "cd ${rootpath}/scripts && ./run_hlstats start >/dev/null 2>&1", user => $user, } ->
  #Daily awards calculations
  cron { 'hlstats-awards': minute => '15', hour => '0', command => "cd ${rootpath}/scripts && ./hlstats-awards.pl >/dev/null 2>&1", user => $user, } ->
  #Daily heatmap generation
  cron { 'hlstats-heatmaps': minute => '45', hour => '0', command => "cd ${rootpath}/heatmaps && php generate.php >/dev/null 2>&1", user => $user, } ->
  #Firewall rule to allow servers to connect to daemon
  firewall { '110 allow hlstatsx access':
    port   => $port,
    proto  => tcp,
    action => accept,
  }
  #Admin user
  hlstatsx::user { $admin_user: password => $admin_pass, update => $admin_update, }
}
