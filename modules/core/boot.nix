{ ... }:
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
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  #boot.kernelPackages = pkgs.linuxPackages-rt_latest;
}
