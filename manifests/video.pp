class kiosk_minimal::video(
  $dirs                     = ['/home/kiosk/','/home/kiosk/.config','/home/kiosk/.config/openbox','/home/kiosk/.icons/','/home/kiosk/.icons/default/','/home/kiosk/.icons/default/cursors'],
  $video                  = undef,
  $rotation               = $kiosk_minimal::rotation,
  $saturation             = '0',
  $contrast               = '0',
)
 {
  # install packages
    package { 'mpv':
      ensure                => installed
    }
  # make userdirs
    file { $dirs:
      ensure                => 'directory',
      require               => User['kiosk'],
      owner                 => 'kiosk',
      group                 => 'kiosk',
      mode                  => '0644'
    }
  # autostart chrome
    file { '/home/kiosk/.config/openbox/autostart.sh':
      ensure                => present,
      mode                  => '0644',
      content               => template("kiosk_minimal/autostart-video.erb"),
      require               => [File['/home/kiosk/.config/openbox']]
    }
 }
