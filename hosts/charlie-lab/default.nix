# charlie-lab — VM VirtualBox, macchina di prova.
#
# Punto di ingresso dell'host: qui sta solo cio' che e' specifico di
# questa macchina (hardware, hostname, account, stateVersion). Tutto il
# resto e' condiviso e vive in ../../modules.
{ pkgs, ... }:
{
  imports = [
    # Risultato di nixos-generate-config: UUID dei filesystem e
    # virtualisation.virtualbox.guest. Da rigenerare su ogni macchina.
    ./hardware-configuration.nix

    ../../modules/core.nix
    ../../modules/desktop.nix
    ../../modules/fonts/fonts.nix
    ../../modules/packages.nix
    ../../modules/programs.nix
  ];

  networking.hostName = "charlie-lab";

  users.users.charlie = {
    isNormalUser = true;
    description = "Stefano Ponzi";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "storage"
      "docker"
      "vboxusers"
    ];
    shell = pkgs.zsh;
    hashedPassword = "***REMOVED-PASSWORD-HASH***";
    packages = with pkgs; [
      tree
    ];
  };

  home-manager = {
    # Home Manager usa il nixpkgs del sistema (niente secondo albero) e
    # installa i pacchetti utente nel profilo, non nella home.
    useGlobalPkgs = true;
    useUserPackages = true;
    # Se un file gestito esiste gia' non-gestito, viene rinominato invece
    # di far fallire l'attivazione.
    backupFileExtension = "hm-bak";

    users.charlie = import ../../home/charlie/charlie.nix;
  };

  # Questa opzione indica la prima versione di NixOS installata su questa
  # macchina e serve a mantenere la compatibilita' con i dati applicativi
  # (database, formati di configurazione dei servizi) creati da versioni
  # precedenti.
  #
  # Non va cambiata dopo l'installazione, per nessun motivo, nemmeno dopo
  # un aggiornamento di release. Non ha alcun effetto sulla versione dei
  # pacchetti, che dipende solo dall'input nixpkgs del flake.
  #
  # Vedi `man configuration.nix` e
  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "25.11";
}
