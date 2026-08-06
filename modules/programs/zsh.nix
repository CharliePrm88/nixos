{ ... }:
{
  # A sistema serve solo abilitare zsh: registra la shell in /etc/shells,
  # altrimenti users.users.charlie.shell = pkgs.zsh non sarebbe valida.
  #
  # Completamento, autosuggestion, syntax highlighting, grml e
  # history-substring-search stanno in Home Manager
  # (home/charlie/console/zsh/zsh.nix). Erano configurati in entrambi i
  # posti, con gli stessi pacchetti e con nomi di opzione diversi fra le
  # due (autosuggestions/autosuggestion, ohMyZsh/oh-my-zsh): era facile
  # modificarne una credendo di modificare l'altra.
  programs.zsh.enable = true;
}
