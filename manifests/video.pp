class kiosk_minimal::video(
  $dirs                     = ['/home/kiosk/','/home/kiosk/.config','/home/kiosk/.config/openbox','/home/kiosk/.icons/','/home/kiosk/.icons/default/','/home/kiosk/.icons/default/cursors'],
  $videourl               = undef,
  $md5                    = undef,
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

    file { "/home/kiosk/video.md5":
      require               => User['kiosk'],
      owner                 => 'kiosk',
      group                 => 'kiosk',
      mode                  => '0644',
      content               => "${md5}  /home/kiosk/video-001.mp4",
    }
    # Bash script to download video
    file { '/home/kiosk/downloadvideo.sh':
      ensure                => present,
      mode                  => '0755',
      content               => template("kiosk_minimal/downloadvideo.sh.erb"),
    }

    exec { "downloadvideo":
      require               => File['/home/kiosk/downloadvideo.sh']
      command               => "/home/kiosk/downloadvideo.sh ${videourl}",
      refreshonly           => true,
      subscribe             => File['/home/kiosk/video.md5'],
    }

  # autostart chrome
    file { '/home/kiosk/.config/openbox/autostart.sh':
      ensure                => present,
      mode                  => '0644',
      content               => template("kiosk_minimal/autostart-video.erb"),
      require               => [File['/home/kiosk/.config/openbox']]
    }
 }
