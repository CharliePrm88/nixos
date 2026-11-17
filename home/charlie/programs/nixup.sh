# Aggiorna gli input del flake, compila il nuovo sistema senza attivarlo,
# mostra le differenze dei pacchetti con nvd e chiede conferma prima di
# `nixos-rebuild switch`. Impacchettato da nixup.nix: lo shebang lo
# aggiunge writeShellApplication.
set -Eeuo pipefail

FLAKE_DIR="/etc/nixos"
HOST="${NIXUP_HOST:-$(hostname)}"
FLAKE_REF="${FLAKE_DIR}#nixosConfigurations.\"${HOST}\".config.system.build.toplevel"
REBUILD_REF="${FLAKE_DIR}#${HOST}"
RESULT_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/nixup"
RESULT_LINK="${RESULT_DIR}/result-${HOST}"
MODE="${1:-update}"

usage() {
    cat <<'USAGE'
Usage: nixup [--check | --dry-run | --diff | --help]

  nixup           Update inputs, build, show package changes, ask to activate
  nixup --check   Check input revisions without modifying flake.lock
  nixup --dry-run Update inputs, build and diff without activating
  nixup --diff    Compare the active system with the last nixup build

If your flake configuration name differs from the hostname:
  NIXUP_HOST=your-config-name nixup
USAGE
}

case "$MODE" in
    update|--check|--dry-run|--diff) ;;
    --help|-h) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
esac

if (( EUID == 0 )); then
    echo 'Run nixup as your regular user (sudo is used only for activation).' >&2
    exit 1
fi

if [[ ! -f "${FLAKE_DIR}/flake.nix" || ! -f "${FLAKE_DIR}/flake.lock" ]]; then
    echo "Missing flake.nix or flake.lock in ${FLAKE_DIR}" >&2
    exit 1
fi

require() {
    local command_name
    for command_name in "$@"; do
        if ! command -v "$command_name" >/dev/null 2>&1; then
            echo "Missing dependency: ${command_name}" >&2
            exit 1
        fi
    done
}

case "$MODE" in
    --check)
        require nix jq cmp mktemp
        tmpdir="$(mktemp -d)"
        trap 'rm -rf "$tmpdir"' EXIT
        echo '==> Checking newer flake input revisions'
        nix flake update --flake "$FLAKE_DIR" \
            --output-lock-file "${tmpdir}/flake.lock"

        if cmp -s "${FLAKE_DIR}/flake.lock" "${tmpdir}/flake.lock"; then
            echo 'All flake inputs are already up to date.'
            exit 0
        fi

        jq -nr \
            --slurpfile before "${FLAKE_DIR}/flake.lock" \
            --slurpfile after "${tmpdir}/flake.lock" '
            ($before[0].nodes // {}) as $old |
            ($after[0].nodes // {}) as $new |
            ($new | keys[]) as $name |
            (($old[$name].locked.rev // $old[$name].locked.narHash // "-") | tostring) as $oldrev |
            (($new[$name].locked.rev // $new[$name].locked.narHash // "-") | tostring) as $newrev |
            select($oldrev != $newrev) |
            "\($name): \($oldrev[0:12]) -> \($newrev[0:12])"
        '
        echo 'No local lock file was modified.'
        exit 0
        ;;
    --diff)
        require nvd
        if [[ ! -e "$RESULT_LINK" ]]; then
            echo 'No previous nixup build found. Run nixup --dry-run first.' >&2
            exit 1
        fi
        echo '==> Changes from active system to last nixup build'
        nvd diff /run/current-system "$RESULT_LINK"
        exit 0
        ;;
esac

require nix nvd
if [[ "$MODE" == update ]]; then
    require nixos-rebuild sudo
fi

echo '==> Updating flake inputs'
nix flake update --flake "$FLAKE_DIR"

mkdir -p "$RESULT_DIR"
echo
echo '==> Building new NixOS system (not activating)'
nix build --out-link "$RESULT_LINK" --print-out-paths "$FLAKE_REF"

echo
echo '==> Package changes'
nvd diff /run/current-system "$RESULT_LINK"

if [[ "$MODE" == --dry-run ]]; then
    echo
    echo 'Build completed; system not activated. flake.lock remains updated.'
    exit 0
fi

echo
read -r -p 'Activate the new system generation? [y/N] ' answer || answer=''
if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    echo 'Activation cancelled; flake.lock remains updated.'
    exit 0
fi

echo
echo '==> Activating new NixOS generation'
sudo nixos-rebuild switch --flake "$REBUILD_REF" --no-update-lock-file

echo
echo '==> Active NixOS version'
nixos-version
