# Scatta una foto dalla webcam a ogni autenticazione PAM fallita e la
# invia su Telegram. Era /usr/local/bin/intruder-snap.sh su Arch.
#
# TELEGRAM_TOKEN e TELEGRAM_CHAT_ID arrivano dall'EnvironmentFile
# ~/.config/intruder-watch/env (fuori dalla repo, vedi
# home/charlie/programs/intruder-watch.nix). Se mancano, la foto viene
# solo salvata.

DIR="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Immagini")/Intruder"
LOCK="${XDG_RUNTIME_DIR:-/tmp}/intruder-camera.lock"
STATE="${XDG_RUNTIME_DIR:-/tmp}/intruder-last-shot"
TOKEN="${TELEGRAM_TOKEN:-}"
CHAT_ID="${TELEGRAM_CHAT_ID:-}"

mkdir -p "$DIR"

take_picture() {
    local now last=0

    now=$(date +%s)

    if [ -f "$STATE" ]; then
        last=$(cat "$STATE" 2>/dev/null || echo 0)
    fi

    # Cooldown di 2 secondi
    if [ $((now - last)) -lt 2 ]; then
        return
    fi

    if ! mkdir "$LOCK" 2>/dev/null; then
        return
    fi

    # shellcheck disable=SC2064
    trap "rmdir '$LOCK' 2>/dev/null" RETURN

    echo "$now" > "$STATE"

    TS=$(date +"%F_%H-%M-%S.%6N")
    IMG="$DIR/intruder_$TS.jpg"

    ffmpeg \
        -y \
        -loglevel error \
        -f v4l2 \
        -video_size 1920x1080 \
        -i /dev/video0 \
        -frames:v 1 \
        "$IMG"

    if [ -n "$TOKEN" ] && [ -n "$CHAT_ID" ] && [ -f "$IMG" ]; then
        curl -s -F chat_id="$CHAT_ID" \
             -F photo=@"$IMG" \
             -F caption="🔒 Tentativo fallito $(hostname) $TS" \
             "https://api.telegram.org/bot$TOKEN/sendPhoto" >/dev/null
    fi
}

journalctl --follow --output=cat | while read -r line; do
    case "$line" in
        *"pam_unix("*")":*authentication*failure*)
            take_picture
            ;;
    esac
done
