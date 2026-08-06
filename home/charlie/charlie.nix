{ ... }:
{
  # Non va cambiata: e' il marcatore di compatibilita' dei dati di Home
  # Manager, non la versione dei pacchetti.
  home.stateVersion = "25.11";

  home.sessionVariables = {
    TERMINAL = "mate-terminal";
  };

  # Imposta XDG_CONFIG_HOME, XDG_CACHE_HOME, XDG_DATA_HOME e
  # XDG_STATE_HOME, e li rende disponibili agli altri moduli Home
  # Manager. Sostituisce il blocco scritto a mano in ~/.zshrc.local, che
  # li esportava solo nelle shell zsh interattive.
  xdg.enable = true;

  imports = [
    ./console/starship/starship.nix
    ./console/zsh/zsh.nix
    ./desktop/i3wm/i3wm.nix
    ./desktop/mate/mate.nix
    ./programs/direnv.nix
    ./programs/git.nix
    ./programs/ssh.nix
  ];
}
