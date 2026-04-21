# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
      ./modules/packages.nix
      ./modules/appearence.nix
    ];

  # Use the systemd-boot EFI boot loader.
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

  networking.hostName = "charlie-lab"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  nixpkgs.config.allowUnfree = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "it_IT.UTF-8";
  console = {
     font = "Lat2-Terminus16";
#     keyMap = "it";
     useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable LightDM
  environment.etc."lightdm/lightdm-gtk-greeter.conf.d".source = ./themes/lightdm/lightdm-gtk-greeter.conf.d;
  services.xserver.displayManager.lightdm.greeters.gtk = {
    enable = true;
    theme = {
      name = "Ambiant-MATE-Dark";
    };
    iconTheme = {
      name = "Ambiant-MATE";
    };
    clock-format = "%a %d %b, %H:%M";
    indicators = [
      "~host"
      "~spacer"
      "~layout"
      "~~"
      "~language"
      "~a11y"
      "~session"
      "~power"
      "~clock"
    ];
  };
  services.xserver.displayManager.lightdm.background = ./themes/radioactive.png;

  #Enable Mate
  services.xserver.desktopManager.mate.enable = true;
  services.xserver.desktopManager.mate.extraCajaExtensions = with pkgs.mate; [
      caja-extensions
    ];
  services.xserver.desktopManager.mate.extraPanelApplets = with pkgs.mate; [
      mate-applets
    ];

  services.xserver.windowManager.i3 = {
		enable = true;
		extraPackages = with pkgs; [
        dmenu #application launcher most people use
        i3status # gives you the default i3 status bar
        i3blocks #if you are planning on using i3blocks over i3status
     ];
  };
  
  # Configure keymap in X11
  services.xserver.xkb.layout = "it";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
   enable = true;
   pulse.enable = true;
   alsa.enable = true;
   alsa.support32Bit = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

security.sudo.wheelNeedsPassword = true;

fonts.packages = with pkgs; [
	noto-fonts
    noto-fonts-cjk-sans
	noto-fonts-color-emoji
	nerd-fonts.noto
	nerd-fonts.symbols-only
];

# Define a user account. Don't forget to set a password with ‘passwd’.
 users.users.charlie = {
   isNormalUser = true;
   description = "Stefano Ponzi";
   extraGroups = [ "wheel"
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

home-manager.users.charlie = import ./home/charlie.nix;

programs.zsh.enable = true;

virtualisation.docker.enable = true;
virtualisation.virtualbox.host.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}
