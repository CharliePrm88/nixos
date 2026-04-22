{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh.enable = false;
  };

  environment.systemPackages = with pkgs; [
    grml-zsh-config
    zsh-history-substring-search
  ];
}
