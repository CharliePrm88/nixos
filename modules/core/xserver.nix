{ ... }:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "it";
  # Come su Arch (/etc/X11/xorg.conf.d/00-keyboard.conf): Ctrl+Alt+Backspace
  # chiude X. Il precedente "eurosign:e,caps:escape" era l'esempio del
  # template NixOS e trasformava Bloc Maiusc in Esc.
  services.xserver.xkb.model = "pc105";
  services.xserver.xkb.options = "terminate:ctrl_alt_bksp";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;
}
