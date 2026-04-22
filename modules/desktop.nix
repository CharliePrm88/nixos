{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./desktop/i3wm.nix
    ./desktop/mate.nix
  ];
}
