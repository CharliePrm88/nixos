{ ... }:
let
  # Nomi dei .desktop su NixOS. Su Arch erano code-oss.desktop,
  # libreoffice-writer/calc.desktop: qui VS Code e LibreOffice li
  # installano con un nome diverso.
  editor = "code.desktop";
  browser = "google-chrome.desktop";
  immagini = "eom.desktop";
  media = "vlc.desktop";
  writer = "writer.desktop";
  calc = "calc.desktop";

  tutti =
    app: tipi:
    builtins.listToAttrs (
      map (t: {
        name = t;
        value = app;
      }) tipi
    );
in
{
  # Le associazioni di ~/.config/mimeapps.list di Arch. Le voci di
  # Pidgin (non installato) e di claude-desktop (non in nixpkgs) sono
  # state lasciate fuori.
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      tutti editor [
        "application/x-zerosize"
        "text/plain"
        "text/html"
        "application/x-shellscript"
        "application/xml"
        "text/csv"
        "image/x-panasonic-rw"
        "text/vnd.trolltech.linguist"
        "application/vnd.apple.keynote"
      ]
      // tutti browser [
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/about"
        "x-scheme-handler/unknown"
        "application/json"
      ]
      // tutti "firefox.desktop" [
        "x-scheme-handler/mailto"
        "application/x-extension-eml"
        "message/rfc822"
      ]
      // tutti immagini [
        "image/bmp"
        "image/gif"
        "image/jpeg"
        "image/png"
        "image/tiff"
      ]
      // tutti media [
        "audio/flac"
        "audio/x-flac"
        "audio/mpeg"
        "audio/x-mpegurl"
        "audio/x-scpls"
        "audio/x-vorbis+ogg"
        "audio/x-wav"
        "video/mp4"
        "video/mpeg"
        "video/mp2t"
        "video/msvideo"
        "video/quicktime"
        "video/webm"
        "video/x-avi"
        "video/x-flv"
        "video/x-matroska"
        "video/x-mpeg"
        "video/x-ogm+ogg"
      ]
      // tutti writer [
        "application/vnd.oasis.opendocument.text"
        "application/rtf"
        "application/msword"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      ]
      // tutti calc [
        "application/vnd.oasis.opendocument.spreadsheet"
        "application/vnd.ms-excel"
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      ]
      // tutti "pluma.desktop" [
        "application/vnd.ms-publisher"
        "application/x-desktop"
      ]
      // {
        "inode/directory" = "caja-folder-handler.desktop";
        "application/pdf" = "atril.desktop";
        "application/x-java" = "intellij-idea.desktop";
        # Registrato da Claude Code stesso in ~/.local/share/applications.
        "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
      };
  };
}
