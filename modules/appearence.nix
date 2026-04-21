
{ config, lib, pkgs, ... }:

{
    environment.systemPackages = [
        (pkgs.stdenv.mkDerivation {
        name = "ambiant-mate-theme";

        src = ../themes/mate;

        installPhase = ''
        mkdir -p $out/share/themes
        mkdir -p $out/share/icons

        cp -r themes/Ambiant-MATE-Dark $out/share/themes/
        cp -r icons/Ambiant-MATE $out/share/icons/
        '';
    })
    ];
}