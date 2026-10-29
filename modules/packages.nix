# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  pkgs,
  ...
}:
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
    rsync

    # =====================================================
    # Android
    # =====================================================
    android-tools
    arduino-cli

    # =====================================================
    # UI / X11
    # =====================================================
    arandr
    flameshot
    xterm
    xss-lock
    feh
    onboard
    plank
    copyq
    xdotool
    pavucontrol

    # =====================================================
    # Networking
    # =====================================================
    filezilla
    # firefox e wireshark sono in modules/programs/ (firefox.nix e
    # wireshark.nix): servono il language pack italiano e il gruppo
    # `wireshark` per catturare senza root.
    qbittorrent
    uget
    dnsutils # dig, nslookup (bind su Arch)
    nettools # ifconfig, netstat, route
    netcat-openbsd
    openssl # CLI: certificati, chiavi, s_client
    mosquitto # client MQTT (mosquitto_pub/sub); il broker non era attivo
    postgresql # client psql; il server non era attivo
    spotify

    # =====================================================
    # Languages / SDK
    # =====================================================
    # Un solo interprete con i moduli dentro: python3 e
    # python3Packages.numpy messi separati in systemPackages non rendono
    # numpy importabile.
    (python3.withPackages (
      ps: with ps; [
        numpy
        matplotlib
        opencv4
        piexif
        pip
        pypdf
        tkinter
      ]
    ))
    ruby
    rustup
    gradle
    maven
    ant
    nodejs_24
    # Il JDK arriva da programs.java (modules/programs/java.nix):
    # metterlo anche qui significava due `java` nel PATH globale.
    visualvm
    soapui

    # =====================================================
    # Office / Docs
    # =====================================================
    libreoffice
    hunspellDicts.it_IT
    hyphenDicts.it_IT
    pandoc
    # asciidoctor + asciidoctor-pdf (e le altre estensioni)
    asciidoctor-with-extensions
    odt2txt
    calibre

    # =====================================================
    # Graphics
    # =====================================================
    blender
    drawing
    qgis
    exiftool

    # =====================================================
    # Misc
    # =====================================================

    lolcat
    cmatrix
    tickrs
    git-filter-repo
    gparted
    usbutils
    ntfs3g
    sbctl
    ddcutil
    lm_sensors
    tpm2-tools
    tpm2-abrmd
    ueberzug
    w3m
    telegram-desktop
    gnuchess
    gnome-chess

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
