# == Class: kiosk_minimal
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
class kiosk_minimal(
  $packages               = ['xorg','openbox','build-essential'],
  $transparent_cursor     = true,
  $disable_keys           = false,
  $enable_remote          = true,
  $rotation               = 'normal',
)
{
  include stdlib
# install packages
  package { $packages:
    ensure                => installed
  }
  if ($transparent_cursor == true)
  {
# download and untar transparent cursor
    exec { 'download_transparent':
      command             => "/usr/bin/curl http://downloads.yoctoproject.org/releases/matchbox/utils/xcursor-transparent-theme-0.1.1.tar.gz -o /tmp/xcursor-transparent-theme-0.1.1.tar.gz && /bin/tar -xf /tmp/xcursor-transparent-theme-0.1.1.tar.gz -C /tmp",
      unless              => "/usr/bin/test -f /tmp/xcursor-transparent-theme-0.1.1.tar.gz",
      require             => [Package[$packages]]
    }
# configure transparent cursor
    exec {"config_transparent":
      command             => "/bin/sh configure",
      cwd                 => "/tmp/xcursor-transparent-theme-0.1.1",
      unless              => "/usr/bin/test -f /home/kiosk/.icons/default/cursors/transp",
      require             => Exec["download_transparent"]
    }
# configure transparent cursor
    exec {"make_transparent":
      command             => "/usr/bin/make install-data-local DESTDIR=/home/kiosk/.icons/default CURSOR_DIR=/cursors -k",
      cwd                 => "/tmp/xcursor-transparent-theme-0.1.1/cursors",
      unless              => "/usr/bin/test -f /home/kiosk/.icons/default/cursors/transp",
      require             => Exec["config_transparent"]
      }
# autoset transparent cursor
    file { '/home/kiosk/.icons/default/cursors/emptycursor':
      ensure              => present,
      mode                => '0644',
      content             => template("kiosk_minimal/emptycursor.erb"),
      require             => Exec["make_transparent"]
    }
# autostart openbox and disable screensaver/blanking + trans cursor
    file { '/home/kiosk/.xinitrc':
      ensure              => present,
      mode                => '0644',
      owner               => 'kiosk',
      content             => template("kiosk_minimal/.xinitrc.erb"),
      require             => [User['kiosk']]
    }
  } else
  {
# autostart openbox and disable screensaver/blanking - trans cursor
    file { '/home/kiosk/.xinitrc':
      ensure              => present,
      mode                => '0644',
      owner               => 'kiosk',
      content             => template("kiosk_minimal/.xinitrc-2.erb"),
      require             => [User['kiosk']]
    }
  }
  if ($disable_keys == true) {
# disable special keys
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
  if ($enable_remote == true) {
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
