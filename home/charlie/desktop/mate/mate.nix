{
  config,
  lib,
  pkgs,
  ...
}: {
  home.file.".face".source = ../face.jpg;
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
