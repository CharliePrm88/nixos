{
  config,
  lib,
  pkgs,
  ...
}: {
  home.stateVersion = "25.11";
  home.sessionVariables = {
    TERMINAL = "mate-terminal";
  }
  imports = [
    ./console/starship/starship.nix
    ./console/zsh/zsh.nix
    ./desktop/i3wm/i3wm.nix
    ./desktop/mate/mate.nix
    ./programs/git.nix
  ];
}
