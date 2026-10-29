{ ... }:
let
  # Plank su Arch puntava a /usr/share/applications/*.desktop. Su NixOS
  # i .desktop stanno nei profili: quello di sistema e quello utente.
  sistema = "/run/current-system/sw/share/applications";

  dockitem = app: ''
    [PlankDockItemPreferences]
    Launcher=file://${sistema}/${app}
  '';
in
{
  xdg.configFile = {
    "plank/dock1/launchers/clock.dockitem".text = ''
      [PlankDockItemPreferences]
      Launcher=docklet://clock
    '';
    "plank/dock1/launchers/google-chrome.dockitem".text = dockitem "google-chrome.desktop";
    "plank/dock1/launchers/mate-terminal.dockitem".text = dockitem "mate-terminal.desktop";
    "plank/dock1/launchers/code.dockitem".text = dockitem "code.desktop";
    "plank/dock1/launchers/intellij-idea.dockitem".text = dockitem "intellij-idea.desktop";
    # webex e' un pacchetto utente (home/charlie/programs/misc.nix).
    "plank/dock1/launchers/webex.dockitem".text = ''
      [PlankDockItemPreferences]
      Launcher=file:///etc/profiles/per-user/charlie/share/applications/webex.desktop
    '';
  };

  dconf.settings."net/launchpad/plank/docks/dock1" = {
    alignment = "center";
    dock-items = [
      "google-chrome.dockitem"
      "mate-terminal.dockitem"
      "code.dockitem"
      "intellij-idea.dockitem"
      "webex.dockitem"
    ];
    lock-items = true;
    offset = 75;
    pinned-only = true;
    position = "right";
    theme = "Gtk+";
    zoom-enabled = true;
  };
}
