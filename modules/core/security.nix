{ ... }:
{
  # sudo chiede sempre la password, anche ai membri di wheel.
  security.sudo.wheelNeedsPassword = true;

  # Gli account sono definiti solo qui: useradd, passwd e usermod non
  # hanno piu' effetto, e un utente tolto dalla configurazione viene
  # rimosso davvero dal sistema invece di sopravvivere in /etc/passwd.
  #
  # Conseguenza da tenere a mente: le password NON si cambiano piu' con
  # `passwd`. Si riscrive il file puntato da hashedPasswordFile e si
  # rifa' `nixos-rebuild switch`. Vedi README.md, sezione "Segreti".
  users.mutableUsers = false;
}
