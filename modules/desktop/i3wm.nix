{
  config,
  lib,
  pkgs,
  ...
}: {
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      dmenu #application launcher most people use
      i3status # gives you the default i3 status bar
      i3blocks #if you are planning on using i3blocks over i3status
      i3lock
    ];
  };
}
