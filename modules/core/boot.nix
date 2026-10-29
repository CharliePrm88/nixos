{ config, pkgs, ... }:
let
  # NixOS chiama la cartella di GRUB nella ESP "NixOS" + mount point
  # della ESP con le "/" sostituite da "-": con la ESP su /boot e'
  # EFI/NixOS-boot (la stessa voce "NixOS-boot" che si vede nel BIOS).
  grubEfi = "${config.boot.loader.efi.efiSysMountPoint}/EFI/NixOS-boot/grubx64.efi";
  # Chiavi create con `sbctl create-keys` (procedura in README.md,
  # §8.4). Si firma con la chiave db.
  sbctlDb = "/var/lib/sbctl/keys/db";
in
{
  boot.loader.systemd-boot.enable = false;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    enableCryptodisk = true;
    # Il menu di GRUB si ferma a 20 generazioni. Senza limite la ESP si
    # riempie di kernel e initrd: con una ESP da 512 MB bastano poche
    # decine di generazioni per esaurirla e far fallire il rebuild.
    # Le voci oltre la ventesima restano comunque nello store finche'
    # non passa il garbage collector (vedi modules/core/nix.nix).
    configurationLimit = 20;
    # Come GRUB_DEFAULT=saved + GRUB_SAVEDEFAULT=true su Arch: riparte
    # dall'ultima voce scelta (utile con os-prober e dual boot).
    default = "saved";

    # Secure Boot senza shim, come su Arch con sbctl: grubx64.efi e i
    # kernel sono firmati con le nostre chiavi e verificati dal firmware.
    # Con il Secure Boot attivo GRUB si mette in lockdown e non carica
    # moduli dal disco, quindi tutti quelli usati da grub.cfg (compresa
    # la voce di Windows di os-prober) vanno inclusi nell'immagine EFI.
    # Cambiare questa lista fa reinstallare GRUB al rebuild successivo.
    extraGrubInstallArgs = [
      "--disable-shim-lock"
      "--modules=all_video boot cat chain configfile echo efifwsetup efi_gop efi_uga ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt help jpeg keystatus linux loadenv ls lsefi minicmd normal ntfs part_gpt part_msdos png probe reboot regexp search search_fs_file search_fs_uuid search_label sleep test tpm true video"
    ];

    # Equivalente dell'hook pacman di sbctl: a ogni rebuild firma
    # grubx64.efi (riscritto quando GRUB viene reinstallato) e i kernel
    # copiati in /boot/kernels, saltando quelli gia' firmati. Gli initrd
    # non sono file EFI e non si possono firmare, come su Arch.
    # Senza chiavi avvisa e non firma, cosi' il rebuild non fallisce.
    extraInstallCommands = ''
      if [ ! -f ${sbctlDb}/db.pem ]; then
        echo "sbctl: chiavi assenti in ${sbctlDb}, niente firma per Secure Boot" >&2
      else
        for f in ${grubEfi} /boot/kernels/*-bzImage; do
          [ -f "$f" ] || continue
          if ! ${pkgs.sbsigntool}/bin/sbverify --cert ${sbctlDb}/db.pem "$f" >/dev/null 2>&1; then
            ${pkgs.sbctl}/bin/sbctl sign "$f"
          fi
        done
      fi
    '';
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  #boot.kernelPackages = pkgs.linuxPackages-rt_latest;
}
