{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    userName = "Stefano Ponzi";
    userEmail = "***REMOVED-WORK-EMAIL***";
  };
}
