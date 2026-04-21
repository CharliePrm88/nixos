# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
 
  environment.systemPackages = with pkgs; [

  # =====================================================
  # Archiving / utils
  # =====================================================
  p7zip
  atool
  unrar
  zip
  unzip

  # =====================================================
  # Audio / Video / Media
  # =====================================================
  alsa-utils
  vlc
  mediainfo
  playerctl
  ffmpegthumbnailer

  # =====================================================
  # Android
  # =====================================================
  android-tools

  # =====================================================
  # UI / X11
  # =====================================================
  arandr
  dmenu
  flameshot
  xterm
  xss-lock
  feh
  onboard
  plank

  # =====================================================
  # i3 WM
  # =====================================================
  i3
  i3status
  i3lock
  i3blocks

  # =====================================================
  # MATE ecosystem
  # =====================================================
  mate.caja-with-extensions
  mate.atril
  mate.engrampa
  mate.eom
  mate.mate-terminal
  mate.mate-system-monitor
  mate.mate-control-center
  mate.mate-power-manager
  mate.mate-screensaver
  mate.mate-utils
  mate.mate-media
  mate.mate-themes
  mate.mate-icon-theme
  mate.mate-icon-theme-faenza
  mate.mozo
  mate.pluma
  mate.mate-panel-with-applets
  mate.mate-applets
  mate.mate-notification-daemon
  mate.mate-polkit
  mate.mate-session-manager
  mate.mate-settings-daemon
  mate.mate-user-share
  mate.mate-backgrounds
  mate.mate-user-guide
  mate.mate-netbook
  mate.mate-sensors-applet
  mate.marco
  mate.libmatekbd
  mate.libmatemixer
  mate.libmateweather
  mate.mate-calc
  mate.mate-control-center
  mate.mate-desktop
  mate.mate-indicator-applet
  mate.mate-utils
  mate.python-caja

  # =====================================================
  # Networking
  # =====================================================
  networkmanagerapplet
  gvfs
  filezilla
  firefox
  openconnect
  openvpn
  wireshark

  # =====================================================
  # CLI / Dev tools
  # =====================================================
  jq
  htop
  strace
  fastfetch
  highlight
  man-db
  nano
  wget
  ranger
  dialog

  # =====================================================
  # Languages / SDK
  # =====================================================
  python3
  python3Packages.numpy
  python3Packages.matplotlib
  ruby
  rustup
  gradle
  maven
  nodejs_24
  javaPackages.compiler.openjdk21
  javaPackages.compiler.openjdk25
  visualvm

  # =====================================================
  # Office / Docs
  # =====================================================
  libreoffice
  pandoc
  asciidoctor
  odt2txt
  calibre

  # =====================================================
  # Graphics
  # =====================================================
  blender
  drawing

  # =====================================================
  # Misc
  # =====================================================
  cowsay
  fortune
  lolcat
  cmatrix
  gparted
  usbutils
  ntfs3g
  sbctl
  tpm2-tools
  tpm2-abrmd
  ueberzug
  w3m
  qbittorrent
  telegram-desktop

  # =====================================================
  # ZSH ecosystem (solo installazione, config dopo)
  # =====================================================
  zsh
  grml-zsh-config
  zsh-autosuggestions
  zsh-history-substring-search
  zsh-syntax-highlighting
  zsh-completions
  starship

  # =====================================================
  # Virtualization
  # =====================================================
  docker-compose

  # =====================================================
  # Unfree / AUR-like
  # =====================================================
  google-chrome
  discord
  vscode
  jetbrains.idea
  jetbrains.datagrip
  jetbrains.webstorm
  android-studio
  ];

}