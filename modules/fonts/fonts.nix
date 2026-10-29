{
  pkgs,
  ...
}:
{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.noto
    nerd-fonts.symbols-only
    # Presenti su Arch (otf-font-awesome, ttf-roboto,
    # ttf-ubuntu-font-family).
    font-awesome
    roboto
    ubuntu-classic
  ];
}
