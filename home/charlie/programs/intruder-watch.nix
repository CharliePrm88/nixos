{
  config,
  pkgs,
  ...
}:
let
  intruderSnap = pkgs.writeShellApplication {
    name = "intruder-snap";
    # Come l'originale: solo `set -u`. Con -e un ffmpeg fallito (webcam
    # occupata) farebbe uscire il loop sul journal.
    bashOptions = [ "nounset" ];
    runtimeInputs = with pkgs; [
      coreutils
      curl
      ffmpeg
      hostname
      systemd
      xdg-user-dirs
    ];
    text = builtins.readFile ./intruder-snap.sh;
  };
in
{
  # Era ~/.config/systemd/user/intruder-watch.service su Arch.
  #
  # Il token del bot Telegram NON sta nella repo (su Arch era scritto
  # nello script). Va in un file locale, da creare una volta sola:
  #
  #     install -d -m 0700 ~/.config/intruder-watch
  #     cat > ~/.config/intruder-watch/env <<'FINE'
  #     TELEGRAM_TOKEN=<token del bot>
  #     TELEGRAM_CHAT_ID=<chat id>
  #     FINE
  #     chmod 0600 ~/.config/intruder-watch/env
  #
  # Il "-" davanti al percorso rende il file opzionale: senza, le foto
  # vengono solo salvate in ~/Immagini/Intruder.
  #
  # Per leggere i messaggi di PAM l'utente deve poter leggere il journal
  # di sistema: gruppo `systemd-journal` (hosts/<host>/default.nix).
  systemd.user.services.intruder-watch = {
    Unit.Description = "Intruder webcam watcher";
    Service = {
      ExecStart = "${intruderSnap}/bin/intruder-snap";
      EnvironmentFile = "-${config.xdg.configHome}/intruder-watch/env";
      Restart = "always";
      RestartSec = 2;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
