{
    home.stateVersion = "25.11";

    home.file.".zshrc.local".source = ./dotfiles/zshrc.local;
    home.file.".config/i3/config".source = ./dotfiles/i3/config;

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
        )
	};
}