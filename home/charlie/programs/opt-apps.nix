{
  config,
  pkgs,
  ...
}:
let
  # Applicazioni che su Arch stavano in /opt (AUR o installer a mano) e
  # che non esistono in nixpkgs. I file dell'applicazione sono stato,
  # non configurazione: vivono in ~/.local/opt, copiati dal backup di
  # Arch. Qui si dichiarano solo il modo di lanciarle e le voci di menu.
  opt = "${config.home.homeDirectory}/.local/opt";

  # SQL Developer e' Java puro: basta dargli un JDK. OIDE_JAVA_HOME e'
  # l'override globale letto da ide/bin/launcher.sh, cosi' non chiede il
  # percorso del JDK al primo avvio. 26.2 vuole Java 17 o superiore.
  sqldeveloper = pkgs.writeShellScriptBin "sqldeveloper" ''
    export OIDE_JAVA_HOME=${pkgs.jdk21}/lib/openjdk
    exec ${pkgs.bash}/bin/bash "${opt}/sqldeveloper/sqldeveloper.sh" "$@"
  '';

  # AsciidocFX porta con se' un JRE e JavaFX precompilati per un sistema
  # FHS: girano dentro un ambiente FHS con le librerie che JavaFX apre
  # a runtime (GTK, X11, GL, ALSA).
  asciidocfx = pkgs.buildFHSEnv {
    name = "asciidocfx";
    targetPkgs =
      p: with p; [
        alsa-lib
        at-spi2-atk
        cairo
        fontconfig
        freetype
        gdk-pixbuf
        glib
        gtk3
        libGL
        libx11
        libxext
        libxi
        libxrender
        libxtst
        libxxf86vm
        pango
        zlib
      ];
    runScript = "${opt}/AsciidocFX/AsciidocFX";
  };
in
{
  home.packages = [
    sqldeveloper
    asciidocfx
  ];

  xdg.desktopEntries = {
    sqldeveloper = {
      name = "SQL Developer";
      exec = "sqldeveloper";
      icon = "${opt}/sqldeveloper/icon.png";
      categories = [ "Development" ];
    };
    asciidocfx = {
      name = "AsciidocFX";
      comment = "Editor di libri e documenti AsciiDoc";
      exec = "asciidocfx %F";
      icon = "accessories-text-editor";
      categories = [
        "Development"
        "Office"
      ];
    };
  };
}
