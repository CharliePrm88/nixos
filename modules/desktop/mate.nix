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
  services.xserver.desktopManager.mate.extraCajaExtensions = with pkgs.mate; [
    caja-extensions
  ];
  services.xserver.desktopManager.mate.extraPanelApplets = with pkgs.mate; [
    mate-applets
  ];
  #dconf.settings = {
  #  "org/mate/desktop/background" = {
  #    picture-filename = "./themes/radioactive.png";
  #  };
  #};

  environment.systemPackages = with pkgs; [
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
