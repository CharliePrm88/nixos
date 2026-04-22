{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.dconf.enable = true;
  services.xserver.enable = true;
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
    (pkgs.stdenv.mkDerivation {
      name = "ambiant-mate-theme";
      src = ../themes/mate;
      installPhase = ''
        mkdir -p $out/share/themes
        mkdir -p $out/share/icons

        cp -r themes/* $out/share/themes/
        cp -r icons/* $out/share/icons/
      '';
    })
  ];
}
