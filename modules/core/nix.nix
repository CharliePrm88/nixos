{ ... }:
{
  # Servono per `nixos-rebuild --flake` e per il comando `nix` unificato.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
