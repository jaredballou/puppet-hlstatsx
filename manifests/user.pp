# == define: hlstatsx::user
#
# Manages a user in HLStatsX
#
# === Parameters
#
# Document parameters here.
#
# [*username*]
# [*password*]
# [*acclevel*]
# [*playerid*]
# [*update*]
#
# === Variables
#
# [*password_md5*]
#   Password hashed into MD5 for MySQL
#
# === Examples
#
#  hlstatsx::user { 'admin':
#    password => 'Password#1',
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
define hlstatsx::user(
  $username = $title,
  $password = 'Password#1',
  $acclevel = 100,
  $playerid = 0,
  $update   = false,
) {
  $password_md5 = md5($password)
  $base_unless = "SELECT username,password FROM ${hlstatsx::db_prefix}_Users WHERE username=\"${username}\""
  $base_command = "INSERT INTO ${hlstatsx::db_prefix}_Users (username,password,acclevel,playerid) VALUES (\"${username}\",\"${password_md5}\",${acclevel},${playerid}) ON DUPLICATE KEY UPDATE acclevel = VALUES(acclevel), playerid = VALUES(playerid)"
  if ($update) {
    $user_unless = $base_unless
    $user_command = $base_command
  } else {
    $user_unless = "${base_unless} AND password=\"${password_md5}\""
    $user_command = "${base_command}, password = VALUES(password)"
  }
  mysqlexec { "hlstatsx-user-${title}":
    host         => $hlstatsx::db_host,
    username     => $hlstatsx::db_user,
    password     => $hlstatsx::db_pass,
    dbname       => $hlstatsx::db_name,
    mysqlcommand => $user_command,
    mysqlunless  => $user_unless,
    logoutput    => 'on_failure',
  }
}
