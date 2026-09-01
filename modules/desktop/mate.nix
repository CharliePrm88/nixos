{
  pkgs,
  ...
}:
{
  programs.dconf.enable = true;

  # Il demone gvfs: e' quello che da' a Caja i segnalibri di rete, il
  # cestino, il mount degli MTP e delle share SMB. Il pacchetto gvfs da
  # solo, in environment.systemPackages, non avviava niente ed e' stato
  # tolto da modules/packages.nix.
  services.gvfs.enable = true;

  # services.xserver.enable sta in modules/core/xserver.nix. Era
  # dichiarato anche qui: due punti da tenere allineati per niente,
  # visto che il modulo core e' sempre importato.
  services.xserver.desktopManager.mate.enable = true;
  services.xserver.desktopManager.mate.extraCajaExtensions = with pkgs; [
    caja-extensions
  ];
  services.xserver.desktopManager.mate.extraPanelApplets = with pkgs; [
    mate-applets
  ];
  #dconf.settings = {
  #  "org/mate/desktop/background" = {
  #    picture-filename = "./themes/radioactive.png";
  #  };
  #};

  environment.systemPackages = with pkgs; [
    caja-with-extensions
    atril
    engrampa
    eom
    mate-terminal
    mate-system-monitor
    mate-control-center
    mate-power-manager
    mate-screensaver
    mate-utils
    mate-media
    mate-themes
    mate-icon-theme
    mate-icon-theme-faenza
    mozo
    pluma
    mate-panel-with-applets
    mate-applets
    mate-notification-daemon
    mate-polkit
    mate-session-manager
    mate-settings-daemon
    mate-user-share
    mate-backgrounds
    mate-user-guide
    mate-netbook
    mate-sensors-applet
    marco
    libmatekbd
    libmatemixer
    libmateweather
    mate-calc
    mate-desktop
    mate-indicator-applet
    python-caja
    # Copia di file, niente da compilare: stdenv.mkDerivation tirava
    # dentro tutto stdenv e le sue fasi (unpack, patch, configure,
    # build, fixup) per poi usarne una sola. runCommand fa lo stesso
    # lavoro senza quel contorno.
    (pkgs.runCommand "ambiant-mate-theme" { } ''
      mkdir -p "$out/share/themes" "$out/share/icons"
      cp -r ${../themes/mate}/themes/. "$out/share/themes/"
      cp -r ${../themes/mate}/icons/. "$out/share/icons/"
    '')
  ];
}
