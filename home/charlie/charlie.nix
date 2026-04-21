{ config, lib, pkgs, ... }:

{
    home.stateVersion = "25.11";

    home.file.".zshrc.local".source = ./dotfiles/zshrc.local;
    home.file.".config/i3/config".source = ./dotfiles/i3wm/config;
	
}