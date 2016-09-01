# == Class: kiosk-minimal
#
# Puppet module to install chrome and local proxy
#
# === Authors
#
# foppe.pieters@naturalis.nl
#
# === Copyright
#
# Copyright 2014
#
class kiosk-minimal(
  $packages                             = ['xorg','openbox','build-essential'],
  $transparent_cursor                   = true,
  $disable_keys                         = false,
  $enable_remote                        = true,
  $function                             = 'video',
)
{
  include stdlib
# install packages
  package { $packages:
    ensure                => installed
  }
  if $function == 'video'
  {
    include kiosk-minimal::video
  }
  else {
    include kiosk-minimal::web
  }
  if ($transparent_cursor )
  {
# download and untar transparent cursor
    exec { 'download_transparent':
      command               => "/usr/bin/curl http://downloads.yoctoproject.org/releases/matchbox/utils/xcursor-transparent-theme-0.1.1.tar.gz -o /tmp/xcursor-transparent-theme-0.1.1.tar.gz && /bin/tar -xf /tmp/xcursor-transparent-theme-0.1.1.tar.gz -C /tmp",
      unless                => "/usr/bin/test -f /tmp/xcursor-transparent-theme-0.1.1.tar.gz",
      require               => [Package[$packages]]
    }
# configure transparent cursor
    exec {"config_transparent":
      command               => "/bin/sh configure",
      cwd                   => "/tmp/xcursor-transparent-theme-0.1.1",
      unless                => "/usr/bin/test -f /home/kiosk/.icons/default/cursors/transp",
      require               => Exec["download_transparent"]
    }
# configure transparent cursor
    exec {"make_transparent":
      command               => "/usr/bin/make install-data-local DESTDIR=/home/kiosk/.icons/default CURSOR_DIR=/cursors -k",
      cwd                   => "/tmp/xcursor-transparent-theme-0.1.1/cursors",
      unless                => "/usr/bin/test -f /home/kiosk/.icons/default/cursors/transp",
      require               => Exec["config_transparent"]
      }
# autoset transparent cursor
    file { '/home/kiosk/.icons/default/cursors/emptycursor':
      ensure                => present,
      mode                  => '0644',
      content               => template("kiosk-minimal/emptycursor.erb"),
      require               => Exec["make_transparent"]
    }
# autostart openbox and disable screensaver/blanking + trans cursor
    file { '/home/kiosk/.xinitrc':
      ensure                => present,
      mode                  => '0644',
      owner                 => 'kiosk',
      content               => template("kiosk-minimal/.xinitrc.erb"),
      require               => [User['kiosk']]
    }
  } else
  {
# autostart openbox and disable screensaver/blanking - trans cursor
    file { '/home/kiosk/.xinitrc':
      ensure                => present,
      mode                  => '0644',
      owner                 => 'kiosk',
      content               => template("kiosk-minimal/.xinitrc-2.erb"),
      require               => [User['kiosk']]
    }
  }
  if ($disable_keys) {
# disable special keys
    file { '/home/kiosk/.xmodmaprc':
      ensure                => present,
      mode                  => '0644',
      owner                 => 'kiosk',
      content               => template("kiosk-minimal/.xmodmaprc.erb"),
      require               => [User['kiosk']]
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
    content               => template("kiosk-minimal/.profile.erb"),
    require               => [User['kiosk']]
  }
# autologin kiosk user
  file { '/etc/systemd/system/getty@tty1.service.d/override.conf':
    ensure                => present,
    mode                  => '0644',
    content               => template("kiosk-minimal/override.conf.erb"),
    require               => [User['kiosk']]
  }
  if ($enable_remote) {
    # setup remote user
      user { "stargazer":
        comment               => "stargazer user",
        home                  => "/home/stargazer",
        ensure                => present,
        managehome            => true,
        password              => sha1('stargazer'),
      }
    ssh_authorized_key { 'stargazer':
      user => 'remote',
      type => 'ssh-rsa',
      key  => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDJSHQMpjAhjdeOqg0NFF7jokYQ4eGWgoINo4Hl8MnW/77POYPOWtkPtJFjRb8MO8tswnipobd0jUr0eIXKKiSIQQzVgQx/gLh0RIfC+OIxOaWktL4n6obo351VykMQO2nevXNaticxbkPD4dwpk/YxeG69u+g90el+P1kwVOxvyqNgcDAvmqLr3nHkw8lTk9pVj4wuU5JYhXvhzPZephX/9+l+KpQ+Ogi3ua05VSoX4Mn1VYsauL7x8t0yC3voPfh2AcT75AWke1Ftdb7k46fPFOCdlZJ0QEH04XrOZwRIJbFpaeXihpn/yFu7Y/MNOa7/kGGWdcbXbUALm4QHb6zh',
    }
  }
}
