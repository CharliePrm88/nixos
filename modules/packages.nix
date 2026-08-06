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

    # =====================================================
    # Android
    # =====================================================
    android-tools

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

    # =====================================================
    # Networking
    # =====================================================
    filezilla
    firefox
    wireshark
    qbittorrent

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
    # Il JDK arriva da programs.java (modules/programs/java.nix):
    # metterlo anche qui significava due `java` nel PATH globale.
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
