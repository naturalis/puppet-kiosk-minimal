# == Class: kiosk_minimal
#
# Puppet module to install minimal kiosk browser
#
# === Authors
#
# foppe.pieters@naturalis.nl
#
# === Copyright
#
# Copyright 2017
#
class kiosk_minimal(
  $packages                = $kiosk_minimal::params::packages,
  $transparent_cursor      = $kiosk_minimal::params::transparent_cursor,
  $disable_keys            = $kiosk_minimal::params::disable_keys,
  $enable_remote           = $kiosk_minimal::params::$enable_remote,
  $function                = $kiosk_minimal::params::$function,
) inherits kiosk_minimal::params {
{
  include stdlib
# install packages
  package { $packages:
    ensure                => installed
  }
  if $function == 'video' {
    contain kiosk_minimal::video
  }
  elsif $function == 'web' {
    contain kiosk_minimal::web
  }
  if $transparent_cursor {
    contain kiosk_minimal::cursor
    ->
    # autostart openbox and disable screensaver/blanking + trans cursor
        file { '/home/kiosk/.xinitrc':
          ensure              => present,
          mode                => '0644',
          owner               => 'kiosk',
          content             => template("kiosk_minimal/.xinitrc.erb"),
          require             => [User['kiosk']]
        }
  }
  else {
    # autostart openbox and disable screensaver/blanking - trans cursor
        file { '/home/kiosk/.xinitrc':
          ensure              => present,
          mode                => '0644',
          owner               => 'kiosk',
          content             => template("kiosk_minimal/.xinitrc-2.erb"),
          require             => [User['kiosk']]
        }
  }
  if $disable_keys {
    file { '/home/kiosk/.xmodmaprc':
      ensure              => present,
      mode                => '0644',
      owner               => 'kiosk',
      content             => template("kiosk_minimal/.xmodmaprc.erb"),
      require             => [User['kiosk']]
    }
  }
# setup kiosk user
  user { "kiosk":
    comment               => "kiosk user",
    home                  => "/home/kiosk",
    ensure                => present,
    managehome            => true,
    password              => sha1('kiosk'),
  }
# startx on login
  file { '/home/kiosk/.profile':
    ensure                => present,
    mode                  => '0644',
    content               => template("kiosk_minimal/.profile.erb"),
    require               => [User['kiosk']],
  }
# autologin kiosk user
  file { '/etc/systemd/system/getty@tty1.service.d':
    ensure                => directory,
    mode                  => '0755',
  }
  file { '/etc/systemd/system/getty@tty1.service.d/override.conf':
    ensure                => present,
    mode                  => '0644',
    content               => template("kiosk_minimal/override.conf.erb"),
    require               => [User['kiosk'], File['/etc/systemd/system/getty@tty1.service.d']],
  }
  if $enable_remote {
  # setup remote user
      user { "stargazer":
        comment           => "stargazer user",
        home              => "/home/stargazer",
        ensure            => present,
        shell             => '/bin/bash',
        groups            => 'wheel',
        managehome        => true,
        password          => sha1('stargazer'),
      }
    ssh_authorized_key { 'stargazer@naturalis':
      user                => 'stargazer',
      type                => 'ssh-rsa',
      key                 => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC+kdUMHaaToYsntgV5vkOvJXDBxUHLxZk7J+J6HtHZ5E7pv6O+d0ksc2aMyHaDl9F7TxUsCATDZErNozFcOx/O5om0SVypxmeewpCtBnXfdNd/HG9sUqvKCOQ/xA+nU+FHI8LtIiQQJ8yUm4GNN2sSRFigY8/GdKMTIpRh/lbBczDkXYjCb6iAV3t8pI7tTtt9z1QnC4vR6sTt7dXTN4ADkmeiIXe1tWkLjk8ptQ0BCjqUgIw1+0f8CisVsiLRJPVANOVg6wR5IlfZWX4XxydOKT/Xl6Bhf517FZC7MGYQ/6bFlUbeIM6svFxqQxcisNGrhpFhZhPXlrs2FHey426d',
    }
  }
}
