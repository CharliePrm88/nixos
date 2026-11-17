{
  pkgs,
  ...
}:
{
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker # TUI per container, immagini e log
  ];
}
