{ ... }:
{
  # Marcatore di compatibilita' dei dati di Home Manager
  home.stateVersion = "26.05";

  # Da ~/.profile e ~/.xprofile di Arch. JAVA_HOME/MAVEN_HOME non
  # servono piu' (modules/programs/java.nix), XDG_* li imposta xdg.enable.
  home.sessionVariables = {
    TERMINAL = "mate-terminal";
    EDITOR = "nano";
    PAGER = "more";
    XFT_FONT = "Noto Sans Regular-10";
    MONOSPACE_FONT = "Noto Sans Mono Regular-10";
  };

  # Imposta XDG_CONFIG_HOME, XDG_CACHE_HOME, XDG_DATA_HOME e
  # XDG_STATE_HOME, e li rende disponibili agli altri moduli Home
  # Manager. Sostituisce il blocco scritto a mano in ~/.zshrc.local, che
  # li esportava solo nelle shell zsh interattive.
  xdg.enable = true;

  # Le cartelle utente in italiano, piu' Progetti (XDG_PROJECTS_DIR),
  # come nel ~/.config/user-dirs.dirs di Arch.
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "$HOME/Scrivania";
    download = "$HOME/Scaricati";
    templates = "$HOME/Modelli";
    publicShare = "$HOME/Pubblici";
    documents = "$HOME/Documenti";
    music = "$HOME/Musica";
    pictures = "$HOME/Immagini";
    videos = "$HOME/Video";
    extraConfig.PROJECTS = "$HOME/Progetti";
  };

  imports = [
    ./console/starship/starship.nix
    ./console/zsh/zsh.nix
    ./desktop/i3wm/i3wm.nix
    ./desktop/mate/mate.nix
    ./desktop/mime.nix
    ./desktop/plank.nix
    ./programs/direnv.nix
    ./programs/git.nix
    ./programs/intruder-watch.nix
    ./programs/jdks.nix
    ./programs/opt-apps.nix
    ./programs/ssh.nix
    ./programs/misc.nix
  ];
}
