{
  pkgs,
  ...
}:
let
  # La config e' quella di Arch, copiata cosi' com'e'. I percorsi FHS che
  # su NixOS non esistono vengono sostituiti qui con quelli nello store,
  # cosi' il file resta confrontabile con l'originale.
  config =
    builtins.replaceStrings
      [
        "/usr/lib/mate-polkit/polkit-mate-authentication-agent-1"
        "/opt/Webex/bin/CiscoCollabHost %U"
      ]
      [
        "${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1"
        "${pkgs.webex}/bin/webex"
      ]
      (builtins.readFile ./config);
in
{
  xdg.configFile."i3/config".text = config;
}
