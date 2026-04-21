{ config, lib, pkgs, ... }:

{
    services.xserver.enable = true;
    services.xserver.desktopManager.mate.enable = true;
    services.xserver.desktopManager.mate.extraCajaExtensions = with pkgs.mate; [
          caja-extensions
        ];
    services.xserver.desktopManager.mate.extraPanelApplets = with pkgs.mate; [
          mate-applets
        ];

    
}