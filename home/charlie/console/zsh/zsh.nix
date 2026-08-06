{
  lib,
  pkgs,
  ...
}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh.enable = false;

    # ~/.zshrc.local veniva installato ma mai letto (il vecchio blocco
    # initExtra era commentato). Adesso viene sourcato davvero.
    #
    # L'ordine conta:
    #   mkBefore (500)  grml-zsh-config, che imposta anche un prompt
    #   mkOrder  (900)  ~/.zshrc.local, che fra le altre cose fa `prompt off`
    #   default  (1000) starship, aggiunto da enableZshIntegration
    initContent = lib.mkMerge [
      (lib.mkBefore ''
        source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
      '')
      (lib.mkOrder 900 ''
        [[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
      '')
    ];
  };

  home.packages = with pkgs; [
    cowsay
    fortune
    grml-zsh-config
    zsh-history-substring-search
  ];

  home.file.".zshrc.local".source = ./zshrc.local;
}
