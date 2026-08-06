{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./programs/docker.nix
    ./programs/git.nix
    ./programs/java.nix
    ./programs/nix-ld.nix
    ./programs/virtualbox.nix
    ./programs/zsh.nix
  ];
}
