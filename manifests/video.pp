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

    file { "/home/kiosk/video-001.md5":
      require               => User['kiosk'],
      owner                 => 'kiosk',
      group                 => 'kiosk',
      mode                  => '0644',
      content               => $md5,
    }

    # Get Google Drive download URL
    exec { "getdriveurl":
      command               => "/usr/bin/curl -c /tmp/cookies ${videourl} > /tmp/drive.html",
      cwd                   => "/tmp",
      creates               => "/tmp/drive.html",
      subscribe             => File['/home/kiosk/video-001.md5'],
      refreshonly           => true,
      notify                => Exec['getvideo']
    }

    exec { "getvideo":
      command               => "/usr/bin/curl -v -L -b /tmp/cookies 'https://drive.google.com$(cat /tmp/drive.html | grep -Po 'uc-download-link' [^>]* href='\\K[^']*' | sed 's/\\&amp;/\\&/g')' > /home/kiosk/video-001.mp4",
      creates               => "/home/kiosk/video-001.mp4",
      user                  => 'kiosk',
      refreshonly           => true,
    }

  # autostart chrome
    file { '/home/kiosk/.config/openbox/autostart.sh':
      ensure                => present,
      mode                  => '0644',
      content               => template("kiosk_minimal/autostart-video.erb"),
      require               => [File['/home/kiosk/.config/openbox']]
    }
 }
