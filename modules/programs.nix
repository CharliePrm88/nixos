{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./programs/docker.nix
    ./programs/git.nix
    ./programs/virtualbox.nix
    ./programs/zsh.nix
  ];
}
