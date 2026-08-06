{ ... }:
{
  programs.direnv = {
    enable = true;
    # nix-direnv sostituisce `use nix` / `use flake` con una versione che
    # tiene in cache l'ambiente e ne registra i GC root: entrare in una
    # cartella non ricostruisce tutto ogni volta, e il garbage collector
    # settimanale (modules/core/nix.nix) non se lo porta via.
    nix-direnv.enable = true;
  };
}
