{ ... }:
let
  # Nomi dei .desktop su NixOS. Su Arch erano code-oss.desktop,
  # libreoffice-writer/calc.desktop: qui VS Code e LibreOffice li
  # installano con un nome diverso.
  editor = "code.desktop";
  browser = "google-chrome.desktop";
  immagini = "eom.desktop";
  media = "vlc.desktop";
  pdf = "atril.desktop";
  libri = "calibre-ebook-viewer.desktop";
  email = "thunderbird.desktop";
  writer = "writer.desktop";
  calc = "calc.desktop";
  impress = "impress.desktop";
  draw = "draw.desktop";

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
  # Le associazioni di ~/.config/mimeapps.list. Regola: tutto cio' che
  # e' testo o codice va a VS Code. Fanno eccezione i documenti da
  # ufficio (LibreOffice), i libri (calibre), i PDF (Atril), i media
  # (VLC), le pagine web (Chrome), le email (Thunderbird) e le immagini
  # (Eye of MATE).
  #
  # I nomi sono quelli canonici di shared-mime-info
  # (share/mime/globs2). Dove un'app puo' ancora usare il nome vecchio
  # (video/x-matroska, application/x-shellscript, ...) e' elencato
  # anche quello: xdg-open fuori da MATE (i3) non risolve gli alias.
  #
  # Le voci di Pidgin (non installato) e di claude-desktop (non in
  # nixpkgs) di Arch sono state lasciate fuori.
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      # text/plain fa anche da ripiego: Caja (GIO) usa il default del
      # tipo padre per i sottotipi di testo non elencati qui.
      tutti editor [
        "text/plain"
        "application/x-zerosize" # file vuoti
        "text/markdown"
        "text/x-markdown"
        "text/x-rst"
        "text/x-log"
        "text/csv"
        "text/x-nix"
        "text/x-shellscript"
        "application/x-shellscript"
        "text/x-python"
        "text/x-python3"
        "text/x-csrc"
        "text/x-chdr"
        "text/x-c++src"
        "text/x-c++hdr"
        "text/x-java"
        "text/x-kotlin"
        "text/x-gradle"
        "text/x-go"
        "text/rust"
        "text/x-lua"
        "application/x-ruby"
        "application/x-perl"
        "application/x-php"
        "application/x-powershell"
        "application/x-bat"
        "text/javascript"
        "application/typescript"
        "text/vnd.trolltech.linguist" # i .ts di TypeScript vengono presi per Qt Linguist
        "text/css"
        "text/x-scss"
        "application/json"
        "application/schema+json"
        "application/x-ipynb+json"
        "application/x-code-workspace"
        "application/yaml"
        "application/toml"
        "application/xml"
        "text/xml"
        "application/sql"
        "text/x-makefile"
        "text/x-cmake"
        "text/x-patch"
        "text/x-tex"
        "text/x-systemd-unit"
        "application/x-desktop"
        "application/x-subrip"
        "text/vtt"
        # Chiavi e certificati: in testo, ma presi per altro
        # (.pub = Publisher, .key = Keynote).
        "text/x-ssh-public-key"
        "application/vnd.ms-publisher"
        "application/vnd.apple.keynote"
        "application/pgp-keys"
        "application/pkcs8"
        "application/x-x509-ca-cert"
        "application/pkix-cert"
        "image/x-panasonic-rw"
      ]
      // tutti browser [
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/about"
        "x-scheme-handler/unknown"
        "text/html"
        "application/xhtml+xml"
        "application/x-mimearchive" # .mht / .mhtml
      ]
      // tutti email [
        "x-scheme-handler/mailto"
        "message/rfc822" # .eml
        "application/x-extension-eml"
        "application/mbox"
      ]
      // tutti pdf [
        "application/pdf"
      ]
      // tutti libri [
        "application/epub+zip"
        "application/x-mobipocket-ebook" # .mobi, .azw
        "application/vnd.amazon.mobi8-ebook" # .azw3, .kfx
        "application/x-mobi8-ebook"
        "application/x-fictionbook+xml" # .fb2
      ]
      // tutti immagini [
        "image/bmp"
        "image/gif"
        "image/jpeg"
        "image/png"
        "image/tiff"
      ]
      // tutti media [
        # Audio
        "audio/mpeg"
        "audio/mp4"
        "audio/aac"
        "audio/ac3"
        "audio/flac"
        "audio/x-flac"
        "audio/ogg"
        "audio/x-vorbis+ogg"
        "audio/x-opus+ogg"
        "audio/x-flac+ogg"
        "audio/vnd.wave"
        "audio/x-wav"
        "audio/x-aiff"
        "audio/x-ms-wma"
        "audio/matroska"
        "audio/webm"
        "audio/x-ape"
        "audio/x-wavpack"
        "audio/midi"
        "audio/AMR"
        # Playlist
        "audio/x-mpegurl"
        "application/vnd.apple.mpegurl"
        "audio/x-scpls"
        # Video
        "video/mp4"
        "video/mpeg"
        "video/x-mpeg"
        "video/mp2t"
        "video/quicktime"
        "video/webm"
        "video/ogg"
        "video/x-theora+ogg"
        "video/x-ogm+ogg"
        "video/matroska"
        "video/x-matroska"
        "video/vnd.avi"
        "video/x-avi"
        "video/msvideo"
        "video/x-msvideo"
        "video/x-flv"
        "video/x-ms-wmv"
        "video/3gpp"
        "video/3gpp2"
      ]
      // tutti writer [
        "application/vnd.oasis.opendocument.text"
        "application/vnd.oasis.opendocument.text-template"
        "application/vnd.oasis.opendocument.text-flat-xml"
        "application/rtf"
        "application/msword"
        "application/msword-template"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.template"
        "application/vnd.ms-word.document.macroEnabled.12"
      ]
      // tutti calc [
        "application/vnd.oasis.opendocument.spreadsheet"
        "application/vnd.oasis.opendocument.spreadsheet-template"
        "application/vnd.oasis.opendocument.spreadsheet-flat-xml"
        "application/vnd.ms-excel"
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        "application/vnd.ms-excel.sheet.macroEnabled.12"
        "application/vnd.ms-excel.sheet.binary.macroEnabled.12"
      ]
      // tutti impress [
        "application/vnd.oasis.opendocument.presentation"
        "application/vnd.oasis.opendocument.presentation-template"
        "application/vnd.ms-powerpoint"
        "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        "application/vnd.openxmlformats-officedocument.presentationml.slideshow"
        "application/vnd.ms-powerpoint.presentation.macroEnabled.12"
      ]
      // tutti draw [
        "application/vnd.oasis.opendocument.graphics"
      ]
      // {
        "inode/directory" = "caja-folder-handler.desktop";
        # I .class compilati: li apre IntelliJ (decompilatore), come su Arch.
        "application/x-java" = "intellij-idea.desktop";
        # Registrato da Claude Code stesso in ~/.local/share/applications.
        "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
      };
  };
}
