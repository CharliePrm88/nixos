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

  dconf.settings = {
    "org/mate/atril/default" = {
      window-ratio = [ 3.2184371430491168 1.2303453517647618 ];
    };

    "org/mate/caja/desktop" = {
      font = "Noto Sans 10";
    };

    "org/mate/caja/list-view" = {
      default-column-order = [ "name" "size" "type" "date_modified" "date_accessed" "date_created" "extension" "group" "where" "mime_type" "octal_permissions" "owner" "permissions" "size_on_disk" "Xattr::Tags" ];
      default-visible-columns = [ "name" "size" "type" "date_modified" "where" ];
    };

    "org/mate/caja/preferences" = {
      always-use-location-entry = true;
      default-folder-viewer = "list-view";
    };

    "org/mate/caja/window-state" = {
      geometry = "958x996+1920+29";
      maximized = true;
      sidebar-width = 113;
      start-with-location-bar = true;
      start-with-sidebar = true;
      start-with-status-bar = true;
      start-with-toolbar = true;
    };

    "org/mate/calc" = {
      button-mode="programming";
	  show-history=false;
	  source-currency="EUR";
	  source-units="degree";
	  target-currency="USD";
	  target-units="radian";
    };

    "org/mate/desktop/accessibility/keyboard" = {
      bouncekeys-beep-reject = true;
      bouncekeys-delay = 300;
      bouncekeys-enable = false;
      enable = false;
      feature-state-change-beep = false;
      mousekeys-accel-time = 1200;
      mousekeys-enable = false;
      mousekeys-init-delay = 160;
      mousekeys-max-speed = 750;
      slowkeys-beep-accept = true;
      slowkeys-beep-press = true;
      slowkeys-beep-reject = false;
      slowkeys-delay = 300;
      slowkeys-enable = false;
      stickykeys-enable = false;
      stickykeys-latch-to-lock = true;
      stickykeys-modifier-beep = true;
      stickykeys-two-key-off = true;
      timeout = 120;
      timeout-enable = false;
      togglekeys-enable = false;
    };

    "org/mate/desktop/applications/at/mobility" = { exec = "onboard"; };
    "org/mate/desktop/applications/at/visual" = { exec = "orca"; };
    "org/mate/desktop/applications/calculator" = { exec = "mate-calc"; };
    "org/mate/desktop/applications/messenger" = { exec = "pidgin"; };
    "org/mate/desktop/applications/terminal" = { exec = "mate-terminal"; };

    "org/mate/desktop/background" = {
  		color-shading-type = "vertical-gradient";
	    picture-filename = "${../../../../modules/themes/radioactive.png}"; 
	    picture-options = "zoom";
	    primary-color = "rgb(88,145,188)";
	    secondary-color = "rgb(60,143,37)";
    };

    "org/mate/desktop/interface" = {
      document-font-name = "Noto Sans 10";
      font-name = "Noto Sans 10";
      gtk-decoration-layout = "menu:minimize,maximize,close";
      gtk-theme = "Ambiant-MATE-Dark";
      icon-theme = "Ambiant-MATE";
      monospace-font-name = "Noto Sans Mono 10";
    };

    "org/mate/desktop/keybindings/custom0" = {
      action = "flameshot gui";
      binding = "Print";
      name = "CatturaSchermataFlameShot";
    };

    "org/mate/desktop/peripherals/keyboard" = { numlock-state = "on"; };
    "org/mate/desktop/peripherals/mouse" = { cursor-theme = "mate"; };

    "org/mate/desktop/sound" = {
      event-sounds = true;
      input-feedback-sounds = true;
      theme-name = "__no_sounds";
    };

    "org/mate/engrampa/dialogs/batch-add" = { default-extension = ".7z"; };
    "org/mate/engrampa/dialogs/extract" = {
      create-subdirectory = false;
      overwrite = true;
      recreate-folders = true;
      skip-newer = false;
    };

    "org/mate/engrampa/general" = {
      encrypt-header = true;
      unar-open-zip = false;
    };

    "org/mate/engrampa/listing" = {
      list-mode = "as-folder";
      name-column-width = 509;
      show-path = false;
      sort-method = "name";
      sort-type = "descending";
    };

    "org/mate/engrampa/ui" = {
      sidebar-width = 200;
      window-height = 1036;
      window-width = 1916;
    };

    "org/mate/eom/ui" = {
      image-collection = false;
      sidebar = false;
    };

    "org/mate/marco/general" = {
      action-double-click-titlebar = "toggle_maximize";
      button-layout = "menu:minimize,maximize,close";
      theme = "Ambiant-MATE-Dark";
      titlebar-font = "Noto Sans 10";
    };

    "org/mate/marco/global-keybindings" = {
      run-command-screenshot = "disabled";
      run-command-terminal = "<Primary><Alt>t";
    };

    "org/mate/notification-daemon" = {
      popup-location = "top_right";
      theme = "coco";
    };

    "org/mate/panel/general" = {
      object-id-list = [ "menu-bar" "notification-area" "clock" "show-desktop" "window-list" "workspace-switcher" "object-2" "object-1" "object-0" "object-4" ];
      toplevel-id-list = [ "top" "bottom" ];
    };

    "org/mate/panel/objects/clock" = {
      applet-iid = "ClockAppletFactory::ClockApplet";
      locked = true;
      object-type = "applet";
      panel-right-stick = true;
      position = 173;
      toplevel-id = "top";
    };

    "org/mate/panel/objects/clock/prefs" = {
      cities = [ "<location name=\"\" city=\"Rome\" timezone=\"Europe/Rome\" latitude=\"41.783333\" longitude=\"12.583333\" code=\"LIRA\" current=\"true\"/>" ];
      expand-locations = true;
      show-temperature = true;
      show-weather = true;
    };

    "org/mate/panel/objects/menu-bar" = {
      locked = true;
      object-type = "menu-bar";
      position = 0;
      toplevel-id = "top";
    };

    "org/mate/panel/objects/notification-area" = {
      applet-iid = "NotificationAreaAppletFactory::NotificationArea";
      locked = true;
      object-type = "applet";
      panel-right-stick = true;
      position = 261;
      toplevel-id = "top";
    };

    "org/mate/panel/objects/object-0" = {
      applet-iid = "TrashAppletFactory::TrashApplet";
      locked = true;
      object-type = "applet";
      panel-right-stick = true;
      position = 24;
      toplevel-id = "bottom";
    };

    "org/mate/panel/objects/object-1" = {
      launcher-location = "mate-terminal-1.desktop";
      object-type = "launcher";
      panel-right-stick = false;
      position = 256;
      toplevel-id = "top";
    };

    "org/mate/panel/objects/object-2" = {
      launcher-location = "google-chrome.desktop";
      object-type = "launcher";
      panel-right-stick = false;
      position = 228;
      toplevel-id = "top";
    };

    "org/mate/panel/objects/object-4" = {
      action-type = "shutdown";
      object-type = "action";
      panel-right-stick = false;
      position = 1916;
      toplevel-id = "top";
    };

    "org/mate/panel/objects/show-desktop" = {
      applet-iid = "WnckletFactory::ShowDesktopApplet";
      locked = true;
      object-type = "applet";
      position = 0;
      toplevel-id = "bottom";
    };

    "org/mate/panel/objects/window-list" = {
      applet-iid = "WnckletFactory::WindowListApplet";
      locked = true;
      object-type = "applet";
      position = 20;
      toplevel-id = "bottom";
    };

    "org/mate/panel/objects/workspace-switcher" = {
      applet-iid = "WnckletFactory::WorkspaceSwitcherApplet";
      locked = true;
      object-type = "applet";
      panel-right-stick = true;
      position = 539;
      toplevel-id = "bottom";
    };

    "org/mate/panel/toplevels/bottom" = {
      expand = true;
      orientation = "bottom";
      screen = 0;
      size = 24;
      y = 1056;
      y-bottom = 0;
    };

    "org/mate/panel/toplevels/top" = {
      expand = true;
      orientation = "top";
      screen = 0;
      size = 24;
    };

    "org/mate/pluma" = {
      background-pattern = "none";
      bottom-panel-size = 140;
      bracket-matching = true;
      color-scheme = "oblivion";
      display-line-numbers = true;
      display-overview-map = false;
      display-right-margin = false;
      highlight-current-line = true;
      side-panel-size = 200;
      size = [ 1916 770 ];
      statusbar-visible = true;
    };

    "org/mate/screensaver" = {
  	  mode = "blank-only";
	  picture-filename = "${../../../../modules/themes/radioactive.png}";
	};

    "org/mate/screenshot" = {
      border-effect = "none";
      delay = 0;
      include-border = false;
      include-pointer = false;
    };

    "org/mate/settings-daemon/plugins/media-keys" = {
      screensaver = "<Shift><Mod4>x";
    };

    "org/mate/settings-daemon/plugins/xrandr" = {
      show-notification-icon = false;
    };

    "org/mate/terminal/profiles/default" = {
      background-color = "#000000000000";
      background-darkness = 0.80483870967741933;
      background-type = "transparent";
      foreground-color = "#0000FFFF0000";
      palette = "#2E2E34343636:#CCCC00000000:#4E4E9A9A0606:#C4C4A0A00000:#34346565A4A4:#757550507B7B:#060698209A9A:#D3D3D7D7CFCF:#555557575353:#EFEF29292929:#8A8AE2E23434:#FCFCE9E94F4F:#72729F9FCFCF:#ADAD7F7FA8A8:#3434E2E2E2E2:#EEEEEEEEECEC";
      use-theme-colors = false;
      visible-name = "Predefinito";
    };
  };
}
