{ ... }:
{
  # Servono per `nixos-rebuild --flake` e per il comando `nix` unificato.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Chrome, VS Code, JetBrains, Discord, Android Studio.
  nixpkgs.config.allowUnfree = true;

  # ===================================================================
  # Manutenzione dello store
  # ===================================================================

  # Senza garbage collection lo store cresce senza limiti: ogni rebuild
  # lascia dietro la generazione precedente e tutte le sue dipendenze.
  # 30 giorni sono abbastanza per poter tornare indietro con calma dopo
  # un aggiornamento andato male.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
    # Non svegliare la macchina solo per fare pulizia; se era spenta al
    # momento previsto, recupera al primo avvio utile.
    persistent = true;
    randomizedDelaySec = "45min";
  };

  # Sostituisce i file identici nello store con hard link. Fa risparmiare
  # parecchio spazio quando piu' generazioni condividono le stesse
  # dipendenze.
  nix.optimise.automatic = true;

  # ===================================================================
  # Aggiornamenti
  # ===================================================================

  # Disattivato di proposito.
  #
  # Con un flake su nixos-unstable, system.autoUpgrade farebbe partire da
  # solo un rebuild su una revisione di nixpkgs mai vista prima, senza
  # che nessuno guardi il risultato. Su unstable questo significa
  # ritrovarsi il desktop rotto dopo un riavvio, con la causa da cercare
  # a posteriori.
  #
  # Inoltre autoUpgrade non aggiorna flake.lock nella repo: aggiornerebbe
  # il sistema lasciando il lock indietro, cioe' proprio la
  # riproducibilita' per cui si e' passati ai flake.
  #
  # L'aggiornamento si fa a mano, quando c'e' tempo di gestire un
  # eventuale problema:
  #
  #     nix flake update                              # muove flake.lock
  #     nixos-rebuild build --flake .#charlie-lab     # prova a costruire
  #     sudo nixos-rebuild switch --flake .#charlie-lab
  #     git commit flake.lock                         # se tutto funziona
  #
  # Se qualcosa non va: `sudo nixos-rebuild switch --rollback`, oppure si
  # sceglie la generazione precedente dal menu GRUB.
  system.autoUpgrade.enable = false;
}
