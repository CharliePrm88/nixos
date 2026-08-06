#!/usr/bin/env bash
# Validazione della configurazione. Va eseguito su una macchina con Nix
# installato (la VM NixOS), dalla radice della repo.
#
#     ./scripts/valida.sh
#
# Non applica niente: nessun `nixos-rebuild switch`.

set -uo pipefail
cd "$(dirname "$0")/.."

esito=0

intestazione() {
	echo
	echo "════════════════════════════════════════════════════════════"
	echo "  $1"
	echo "════════════════════════════════════════════════════════════"
}

esegui() {
	local nome="$1"
	shift
	intestazione "$nome"
	echo "\$ $*"
	echo
	if "$@"; then
		echo "  --> OK"
	else
		echo "  --> FALLITO"
		esito=1
	fi
}

# Il flake vede solo i file tracciati da git: un file nuovo e non
# aggiunto risulta semplicemente inesistente, con errori incomprensibili.
if [ -n "$(git status --porcelain --untracked-files=all -- '*.nix' 'flake.lock')" ]; then
	intestazione "ATTENZIONE: file .nix non tracciati o non in stage"
	git status --short --untracked-files=all -- '*.nix' 'flake.lock'
	echo
	echo "  Il flake non li vedra'. Fai `git add` prima di continuare."
fi

esegui "nix flake check" \
	nix flake check

esegui "build del sistema" \
	nixos-rebuild build --flake .#charlie-lab

esegui "build della VM di prova" \
	nixos-rebuild build-vm --flake .#charlie-lab

esegui "statix" \
	nix run nixpkgs#statix -- check .

esegui "deadnix" \
	nix run nixpkgs#deadnix -- .

# `nix fmt` riscrive i file invece di limitarsi a segnalare: qui si
# controlla solo che non ci sia niente da riformattare.
intestazione "nixfmt (solo controllo)"
echo "\$ nix fmt -- --check ."
echo
if nix fmt -- --check .; then
	echo "  --> OK"
else
	echo "  --> ci sono file da riformattare: esegui  nix fmt  e committa il diff"
	esito=1
fi

intestazione "RISULTATO"
if [ "$esito" -eq 0 ]; then
	echo "  Tutto a posto."
else
	echo "  Qualcosa non e' passato: vedi sopra."
fi
exit "$esito"
