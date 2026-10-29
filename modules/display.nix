# modules/display.nix
{ pkgs, ... }:
{
  hardware.i2c.enable = true;
  users.users.charlie.extraGroups = [ "i2c" ];
  environment.systemPackages = [ pkgs.ddcutil ];
}
