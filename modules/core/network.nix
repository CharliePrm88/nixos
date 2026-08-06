{
  config,
  lib,
  pkgs,
  ...
}: {
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # networking.hostName sta in hosts/<host>/default.nix: e' specifico
  # della macchina, questo modulo e' condiviso fra tutti gli host.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    openconnect
    openvpn
  ];
}
