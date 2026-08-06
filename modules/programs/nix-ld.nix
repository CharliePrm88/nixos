{ ... }:
{
  # Fa funzionare i binari dinamici precompilati che si aspettano un
  # sistema FHS: installer scaricati a mano, language server e toolchain
  # tirate giu' da rustup, npm o dai plugin di JetBrains, che su NixOS
  # altrimenti falliscono con "No such file or directory" perche' cercano
  # /lib64/ld-linux-x86-64.so.2.
  programs.nix-ld.enable = true;
}
