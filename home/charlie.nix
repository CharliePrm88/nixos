{ config, lib, pkgs, ... }:

{
    home.stateVersion = "25.11";

    home.file.".zshrc.local".source = ./dotfiles/zshrc.local;
    home.file.".config/i3/config".source = ./dotfiles/i3wm/config;
    home.file.".face".source = ./dotfiles/faces.jpg;
 
    gtk = {
        enable = true;
 
        theme = {
            name = "Ambiant-MATE-Dark";
        };
 
        iconTheme = {
            name = "Ambiant-MATE";
        };
    };

    programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        oh-my-zsh.enable = false;
        
        initContent = lib.mkBefore ''
            source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
        '';
    };

	programs.starship = {
		enable = true;
        enableZshIntegration = true;
        settings = builtins.fromTOML (
            builtins.readFile ./dotfiles/starship.toml
        );
	};
}