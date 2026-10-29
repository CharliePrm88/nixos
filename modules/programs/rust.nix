{
  pkgs,
  lib,
  ...
}:
{
environment.systemPackages = with pkgs; [
    rustup
    gcc
    jetbrains.rust-rover
  ];
}
