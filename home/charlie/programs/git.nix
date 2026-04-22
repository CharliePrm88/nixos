{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    settings.user.name = "Stefano Ponzi";
    settings.user.email = "***REMOVED-WORK-EMAIL***";
  };
}
