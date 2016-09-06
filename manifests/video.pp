class kiosk_minimal::video(
  $dirs                     = ['/home/kiosk/','/home/kiosk/.config','/home/kiosk/.config/openbox','/home/kiosk/.icons/','/home/kiosk/.icons/default/','/home/kiosk/.icons/default/cursors'],
  $urlvideo1              = undef,
  $md5video1              = undef,
  $urlvideo2              = undef,
  $md5video2              = undef,
  $rotation               = 'normal',
  $saturation             = '0',
  $contrast               = '0',
  $tmpdir                 = '/tmp/video',
)
 {
    # Install packages
    package { 'mpv':
      ensure                => installed
    }
    # Make userdirs
    file { $dirs:
      ensure                => 'directory',
      require               => User['kiosk'],
      owner                 => 'kiosk',
      group                 => 'kiosk',
      mode                  => '0644'
    }

    # Bash script to download video
    file { '/home/kiosk/downloadvideo.sh':
      ensure                => present,
      mode                  => '0755',
      content               => template("kiosk_minimal/downloadvideo.sh.erb"),
    }

    # If defined get video 1
    if $urlvideo1 {
      # Create MD5 file for video1
      file { "/home/kiosk/video1.md5":
        require               => User['kiosk'],
        owner                 => 'kiosk',
        group                 => 'kiosk',
        mode                  => '0644',
        content               => "${md5video1}  ${tmpdir}/video1.mp4",
      }

      # Download video1 after MD5 has changed
      exec { "downloadvideo":
        require               => File['/home/kiosk/downloadvideo.sh'],
        command               => "/home/kiosk/downloadvideo.sh ${urlvideo1} video1",
        refreshonly           => true,
        subscribe             => File['/home/kiosk/video1.md5'],
      }
    }

    # If defined get video 2
    if $urlvideo2 {
      # Get Video 2
      # Create MD5 file for video1
      file { "/home/kiosk/video2.md5":
        require               => User['kiosk'],
        owner                 => 'kiosk',
        group                 => 'kiosk',
        mode                  => '0644',
        content               => "${md5video2}  ${tmpdir}/video2.mp4",
      }

      # Download video2 after MD5 has changed
      exec { "downloadvideo":
        require               => File['/home/kiosk/downloadvideo.sh'],
        command               => "/home/kiosk/downloadvideo.sh ${urlvideo2} video2",
        refreshonly           => true,
        subscribe             => File['/home/kiosk/video2.md5'],
      }
    }

  # Autostart MPV and loop the video's
    file { '/home/kiosk/.config/openbox/autostart.sh':
      ensure                => present,
      mode                  => '0644',
      content               => template("kiosk_minimal/autostart-video.erb"),
      require               => [File['/home/kiosk/.config/openbox']]
    }
 }
