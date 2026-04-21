{ config, lib, pkgs, ... }:

{
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
}