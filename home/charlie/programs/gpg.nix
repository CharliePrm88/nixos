{ pkgs, ... }:
{
  # GnuPG: installa gpg e usa ~/.gnupg, il portachiavi gia' presente.
  # Le chiavi restano fuori dalla repo: si importano a mano da backup
  # (vedi README.md) o si creano con `gpg --full-generate-key`.
  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    # pinentry-gnome3 chiede la passphrase tramite il prompter di gcr, che
    # gira anche su MATE e i3 perche' arriva su D-Bus con
    # services.gnome.gnome-keyring (modules/qol.nix). Senza display
    # ripiega sul terminale.
    pinentry.package = pkgs.pinentry-gnome3;
    # enableSshSupport resta spento: SSH_AUTH_SOCK lo gestisce gia'
    # services.ssh-agent (ssh.nix) e i due si contenderebbero il socket.
  };
}
