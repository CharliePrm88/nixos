{ ... }:
{
  # Webex si aggiorna da solo in ~/.local/share/WebexLauncher e il
  # launcher del pacchetto carica da li' libWebexVersionSelector.so, che
  # non e' patchata per NixOS: senza queste librerie esce subito con
  # "libX11.so.6: cannot open shared object file" (vedi
  # ~/.local/share/Webex/hostLogs/webexhost.txt).
  #
  # L'overlay sostituisce pkgs.webex ovunque (anche in Home Manager, che
  # usa i pkgs di sistema): bin/webex diventa un wrapper con le librerie
  # nel LD_LIBRARY_PATH, e il .desktop punta al wrapper invece che a
  # CiscoCollabHost.
  nixpkgs.overlays = [
    (final: prev: {
      webex = prev.symlinkJoin {
        name = "webex-${prev.webex.version}";
        inherit (prev.webex) version meta;
        paths = [ prev.webex ];
        nativeBuildInputs = [ prev.makeWrapper ];
        postBuild = ''
          rm $out/bin/webex
          makeWrapper ${prev.webex}/opt/Webex/bin/CiscoCollabHost $out/bin/webex \
            --prefix LD_LIBRARY_PATH : ${
              prev.lib.makeLibraryPath [
                prev.glib
                prev.libx11
                prev.libxscrnsaver
              ]
            }

          rm $out/share/applications/webex.desktop
          substitute ${prev.webex}/share/applications/webex.desktop \
            $out/share/applications/webex.desktop \
            --replace-fail "Exec=${prev.webex}/opt/Webex/bin/CiscoCollabHost" "Exec=$out/bin/webex"
        '';
      };
    })
  ];
}
