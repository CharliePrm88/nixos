{
  pkgs,
  ...
}:
{
  # Crea il gruppo `wireshark` e il wrapper di dumpcap con le capability
  # per catturare senza root, come wireshark-qt su Arch. L'utente deve
  # stare nel gruppo (hosts/<host>/default.nix).
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
}
