{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh.enable = false;

    initContent = lib.mkBefore ''
      source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
    '';
    #initExtra = ''
    # zshrc.local TODO
    #''
  };

  home.packages = with pkgs; [
    cowsay
    fortune
    grml-zsh-config
    zsh-history-substring-search
  ];

  home.file.".zshrc.local".source = ./zshrc.local;
}
