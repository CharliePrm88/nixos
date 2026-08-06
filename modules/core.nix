{ ... }:
{
  imports = [
    ./core/audio.nix
    ./core/boot.nix
    ./core/console.nix
    ./core/lightdm.nix
    ./core/network.nix
    ./core/nix.nix
    ./core/security.nix
    ./core/time.nix
    ./core/xserver.nix
  ];
}
