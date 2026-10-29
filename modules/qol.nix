# Qualita' di vita: cose che non appartengono a nessuno dei moduli
# esistenti ma che ci si aspetta da un desktop funzionante.
{ ... }:
{
  # ===================================================================
  # Memoria
  # ===================================================================

  # Swap compressa in RAM. Utile soprattutto su questa VM, dove la RAM e'
  # poca e i rebuild sono avidi: evita l'OOM killer a meta' build senza
  # dover dichiarare uno swapfile su disco.
  zramSwap.enable = true;

  # ===================================================================
  # Sessione
  # ===================================================================

  # LightDM offre sia MATE sia i3. Senza questa riga la sessione
  # preselezionata dipende dall'ordine con cui vengono trovati i file
  # .desktop, e cambia sotto i piedi a ogni aggiornamento.
  services.displayManager.defaultSession = "mate";

  # Portachiavi sbloccato al login invece che a ogni richiesta: e' quello
  # che tiene le passphrase delle chiavi SSH, i token di GNOME Online
  # Accounts e le credenziali salvate da Chrome.
  services.gnome.gnome-keyring.enable = true;
  # Senza questa riga il portachiavi esiste ma resta bloccato: e' PAM che
  # deve passargli la password digitata al login.
  security.pam.services.lightdm.enableGnomeKeyring = true;

  # ===================================================================
  # Applicazioni
  # ===================================================================

  # Le AppImage sono binari FHS: su NixOS non partono da sole. Con
  # binfmt il kernel le riconosce e le esegue direttamente, senza doverle
  # lanciare a mano tramite appimage-run.
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # ===================================================================
  # Stampa e rete locale
  # ===================================================================

  services.printing.enable = true;

  # ===================================================================
  # Accessibilita'
  # ===================================================================

  # Lettore di schermo Orca (impostato in dconf come applicazione
  # "visual" di MATE) con speech-dispatcher, come su Arch.
  services.orca.enable = true;
  services.speechd.enable = true;

  # Avahi serve a CUPS per trovare le stampanti di rete da solo (IPP
  # Everywhere / AirPrint): senza, le stampanti vanno aggiunte a mano per
  # indirizzo. nssmdns4 fa risolvere anche i nomi .local.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # ===================================================================
  # Hardware
  # ===================================================================

  # Inerte sulla VM (VirtualBox non passa il controller Bluetooth), ma il
  # modulo e' condiviso con il futuro host bare metal.
  hardware.bluetooth.enable = true;
  # Applet e gestore grafico, come blueman su Arch (bluez-obex incluso:
  # invio/ricezione file).
  services.blueman.enable = true;

  # TPM2: su Arch c'erano tpm2-tools e tpm2-abrmd col servizio attivo.
  # tss2/abrmd danno l'accesso al TPM senza root ai membri di `tss`.
  security.tpm2 = {
    enable = true;
    abrmd.enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  # ddcutil (luminosita' dei monitor esterni via DDC/CI): serve il bus
  # i2c accessibile al gruppo `i2c`.
  hardware.i2c.enable = true;

  # Aggiornamenti firmware via LVFS: `fwupdmgr refresh && fwupdmgr
  # update`. Anche questo inerte sulla VM, utile sul bare metal.
  services.fwupd.enable = true;

  # ===================================================================
  # Docker
  # ===================================================================

  # Immagini e layer scaricati non vengono mai rimossi da soli, e su una
  # macchina di sviluppo diventano decine di GB. Il timer predefinito e'
  # settimanale.
  virtualisation.docker.autoPrune.enable = true;
}
