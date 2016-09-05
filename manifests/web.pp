class kiosk_minimal::web(
  $dirs                   = ['/home/kiosk/','/home/kiosk/.config','/home/kiosk/.config/google-chrome','/home/kiosk/.config/google-chrome/Default','/home/kiosk/.config/google-chrome/Default/Extensions','/home/kiosk/.config/openbox','/home/kiosk/.icons/','/home/kiosk/.icons/default/','/home/kiosk/.icons/default/cursors'],
  $start                  = $kiosk_minimal::start,
  $rotation               = $kiosk_minimal::rotation,
)
 {
   # install google-chrome
  file { "/etc/apt/sources.list.d/google.list":
    owner                 => 'kiosk',
    group                 => 'kiosk',
    mode                  => '0444',
    content               => "deb [arch=amd64] http://dl.google.com/linux/deb/ stable main",
    notify                => Exec["Google apt-key"],
  }
# Add Google's apt-key.
  exec { "Google apt-key":
    command               => "/usr/bin/wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | /usr/bin/apt-key add -",
    refreshonly           => true,
    notify                => Exec["apt-get update"],
  }
# refresh:
  exec { "apt-get update":
    command               => "/usr/bin/apt-get update",
    refreshonly           => true,
  }
# Install latest stable
  package { "google-chrome-stable":
    ensure                => latest,
    require               => [ Exec["apt-get update"]],
  }
  # make userdirs
  file { $dirs:
    ensure                => 'directory',
    require               => User['kiosk'],
    owner                 => 'kiosk',
    group                 => 'kiosk',
    mode                  => '0644'
  }
  # ensure google-chrome config file
  file { '/home/kiosk/.config/google-chrome/Local State':
    ensure                => present,
    owner                 => 'kiosk',
    group                 => 'kiosk',
    mode                  => '0600',
    content               => template("kiosk_minimal/chrome-config.erb"),
    require               => [User['kiosk']]
  }
# improve scrollbar
  file { '/home/kiosk/.config/google-chrome/Default/Extensions/manifest.json':
    ensure                => present,
    owner                 => 'kiosk',
    group                 => 'kiosk',
    mode                  => '0755',
    content               => template("kiosk_minimal/chrome-manifest.erb"),
    require               => [Package['google-chrome-stable'],File[$dirs]]
  }
  file { '/home/kiosk/.config/google-chrome/Default/Extensions/Custom.css':
    ensure                => present,
    owner                 => 'kiosk',
    group                 => 'kiosk',
    mode                  => '0755',
    content               => template("kiosk_minimal/chrome-css.erb"),
    require               => [Package['google-chrome-stable'],File[$dirs]]
  }
  file { '/home/kiosk/.config/google-chrome/Default/Extensions/Custom.js':
    ensure                => present,
    owner                 => 'kiosk',
    group                 => 'kiosk',
    mode                  => '0755',
    content               => template("kiosk_minimal/chrome-js.erb"),
    require               => [Package['google-chrome-stable'],File[$dirs]]
  }
# autostart chrome
  file { '/home/kiosk/.config/openbox/autostart.sh':
    ensure                => present,
    mode                  => '0644',
    content               => template("kiosk_minimal/autostart-web.erb"),
    require               => [File['/home/kiosk/.config/openbox']]
    }
 }
