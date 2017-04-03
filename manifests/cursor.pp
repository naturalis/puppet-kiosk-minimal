class kiosk_minimal::cursor(
  $packages               = $kiosk_minimal::params::packages,
) {
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
}
