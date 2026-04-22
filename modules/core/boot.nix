{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.loader.systemd-boot.enable = false;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    enableCryptodisk = true;
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  #boot.kernelPackages = pkgs.linuxPackages-rt_latest;
}
