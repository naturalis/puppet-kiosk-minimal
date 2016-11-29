class kiosk_minimal::video(
  $dirs                    = ['/home/kiosk/','/home/kiosk/.config','/home/kiosk/.config/openbox','/home/kiosk/.icons/','/home/kiosk/.icons/default/','/home/kiosk/.icons/default/cursors'],
  $video1_url              = undef,
  $video1_md5              = undef,
  $video2_url              = undef,
  $video2_md5              = undef,
  $rotation                = 'normal',
  $saturation              = '0',
  $contrast                = '0',
  $brightness              = '0',
  $video_output            = 'vaapi',
  $rgb_color               = undef,
  $hardware_decoder        = 'vaapi',
  $av_sync                 = undef,
  $vd_threads              = '0',
  $fullscreen              = 'yes',
  $volume                  = undef,
  $tmpdir                  = '/tmp/video',
)
 {
    # Install packages
    package { 'mpv':
      ensure                => installed
    }
    # install alsa for audio
    package { 'alsa':
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

    #set mpv config
    file { "/etc/mpv/mpv.conf":
      require               => Package['mpv'],
      mode                  => '0644',
      content               => template("kiosk_minimal/mpv.conf.erb"),
    }
    # If defined get video 1
    if $video1_url {
      # Create MD5 file for video1
      file { "/home/kiosk/video1.md5":
        require               => User['kiosk'],
        owner                 => 'kiosk',
        group                 => 'kiosk',
        mode                  => '0644',
        content               => "${video1_md5}  ${tmpdir}/video1.mp4",
      }

      # Download video1 after MD5 has changed
      exec { "downloadvideo1":
        require               => File['/home/kiosk/downloadvideo.sh'],
        command               => "/home/kiosk/downloadvideo.sh '${video1_url}' 'video1'",
        refreshonly           => true,
        subscribe             => File['/home/kiosk/video1.md5'],
      }
    }

    # If defined get video 2
    if $video2_url {
      # Get Video 2
      # Create MD5 file for video1
      file { "/home/kiosk/video2.md5":
        require               => User['kiosk'],
        owner                 => 'kiosk',
        group                 => 'kiosk',
        mode                  => '0644',
        content               => "${video2_md5}  ${tmpdir}/video2.mp4",
      }

      # Download video2 after MD5 has changed
      exec { "downloadvideo2":
        require               => File['/home/kiosk/downloadvideo.sh'],
        command               => "/home/kiosk/downloadvideo.sh '${video2_url}' 'video2'",
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
