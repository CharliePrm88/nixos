{
  config,
  lib,
  pkgs,
  ...
}: {
  i18n.defaultLocale = "it_IT.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    #     keyMap = "it";
    useXkbConfig = true; # use xkb.options in tty.
  };

  environment.systemPackages = with pkgs; [
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
  ];
}
