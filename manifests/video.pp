class kiosk-minimal::video(
  $dirs                                 = ['/home/kiosk/','/home/kiosk/.config','/home/kiosk/.config/openbox','/home/kiosk/.icons/','/home/kiosk/.icons/default/','/home/kiosk/.icons/default/cursors'],
  $start                                = 'mpv --fs --hwdec=vaapi --vo=vaapi --loop=inf --saturation=-35 --no-osc /home/kiosk/test.avi /home/kiosk/test2.avi',
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
      content               => "${start}",
      require               => [File['/home/kiosk/.config/openbox']]
    }
 }
