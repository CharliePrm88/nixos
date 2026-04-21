
{ config, lib, pkgs, ... }:

{
    environment.systemPackages = [
        (pkgs.stdenv.mkDerivation {
        name = "ambiant-mate-theme";

        src = ../themes/mate;

        installPhase = ''
        mkdir -p $out/share/themes
        mkdir -p $out/share/icons

        cp -r themes/* $out/share/themes/
        cp -r icons/* $out/share/icons/
        '';
    })
    ];
}