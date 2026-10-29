{
  pkgs,
  ...
}:
{
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # networking.hostName sta in hosts/<host>/default.nix: e' specifico
  # della macchina, questo modulo e' condiviso fra tutti gli host.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Plugin VPN per NetworkManager: i profili importati da Arch usano
  # OpenConnect e OpenVPN. Senza plugin compaiono nell'applet ma non si
  # connettono.
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openconnect
    networkmanager-openvpn
  ];

  # Su Arch era in /etc/hosts: i container e i test (Testcontainers)
  # raggiungono l'host con lo stesso nome usato da Docker Desktop.
  networking.extraHosts = ''
    127.0.0.1 host.docker.internal
  '';

  # Stessi server di /etc/ntp.conf su Arch, usati qui da timesyncd.
  networking.timeServers = [
    "0.it.pool.ntp.org"
    "1.it.pool.ntp.org"
    "2.it.pool.ntp.org"
    "3.it.pool.ntp.org"
  ];

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
    openfortivpn
    wireguard-tools
    wirelesstools
  ];
}
