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
    ../../modules/qol.nix
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

    # L'hash NON sta nella repo: sta in un file fuori dal versionamento,
    # letto all'attivazione. Il file deve esistere PRIMA del primo
    # switch, altrimenti l'account resta senza password valida e, con
    # users.mutableUsers = false, non c'e' modo di impostarla da dentro
    # il sistema.
    #
    # Procedura completa in README.md, sezione "Segreti".
    # In breve:
    #     sudo install -d -m 0700 /etc/secrets
    #     mkpasswd -m sha-512 | sudo tee /etc/secrets/charlie.hashedPassword
    #     sudo chmod 0600 /etc/secrets/charlie.hashedPassword
    hashedPasswordFile = "/etc/secrets/charlie.hashedPassword";

    packages = with pkgs; [
      tree
    ];
  };

  # Password di root separata: e' la via di rientro se il file di
  # charlie manca o e' sbagliato. Se il file non esiste, root resta
  # semplicemente bloccato (l'attivazione avvisa ma non fallisce).
  users.users.root.hashedPasswordFile = "/etc/secrets/root.hashedPassword";

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
