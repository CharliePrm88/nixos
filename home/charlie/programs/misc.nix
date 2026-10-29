{
  pkgs,
  ...
}:{
home.packages = with pkgs; [
    webex
    claude-code
  ];
}
