{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.etc."lightdm/lightdm-gtk-greeter.conf.d".source = ./themes/lightdm/lightdm-gtk-greeter.conf.d;
  services.xserver.displayManager.lightdm.greeters.gtk = {
    enable = true;
    theme = {
      name = "Ambiant-MATE-Dark";
    };
    iconTheme = {
      name = "Ambiant-MATE";
    };
    clock-format = "%a %d %b, %H:%M";
    indicators = [
      "~host"
      "~spacer"
      "~layout"
      "~~"
      "~language"
      "~a11y"
      "~session"
      "~power"
      "~clock"
    ];
  };
  services.xserver.displayManager.lightdm.background = ./themes/radioactive.png;
}
