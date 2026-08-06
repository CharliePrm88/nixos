# nixos

Configurazione NixOS dichiarativa di `charlie-lab` — sistema + [Home Manager](https://github.com/nix-community/home-manager), organizzata in moduli.

Questo README descrive la procedura completa per **reinstallare la macchina da zero** a partire da questa repo.

> [!IMPORTANT]
> **Aggiornare la versione prima di installare.**
> La repo è attualmente allineata a **NixOS 25.11** ("Xantusia"), il cui supporto è terminato il **30/06/2026**.
> La release stabile corrente è **26.05** ("Yarara", rilasciata il 30/05/2026). Prima di procedere, sostituire `25.11` con la versione stabile attuale in **tutti** i punti elencati in [§7 — Allineare la versione](#7-allineare-la-versione). Verificare la release corrente su <https://nixos.org/download/>.

---

## Indice

1. [Cosa contiene la repo](#1-cosa-contiene-la-repo)
2. [Caratteristiche del sistema installato](#2-caratteristiche-del-sistema-installato)
3. [Preparare il supporto di installazione](#3-preparare-il-supporto-di-installazione)
4. [Partizionamento e formattazione](#4-partizionamento-e-formattazione)
5. [Montaggio](#5-montaggio)
6. [Clonare la repo e generare l'hardware-configuration](#6-clonare-la-repo-e-generare-lhardware-configuration)
7. [Allineare la versione](#7-allineare-la-versione)
8. [Channel (nixos + home-manager)](#8-channel-nixos--home-manager)
9. [Installazione](#9-installazione)
10. [Primo avvio e post-installazione](#10-primo-avvio-e-post-installazione)
11. [Manutenzione ordinaria](#11-manutenzione-ordinaria)
12. [Note e trappole note](#12-note-e-trappole-note)
13. [Segreti](#13-segreti)

---

## 1. Cosa contiene la repo

```
.
├── configuration.nix              # entry point: utente, imports, stateVersion
├── hardware-configuration.nix     # DA RIGENERARE su ogni macchina (vedi §6)
├── modules/                       # configurazione di sistema
│   ├── core.nix                   #   → audio, boot, console, lightdm, network, time, xserver
│   ├── desktop.nix                #   → i3wm, mate
│   ├── fonts/fonts.nix            #   Noto + Nerd Fonts
│   ├── packages.nix               #   environment.systemPackages
│   ├── programs.nix               #   → docker, git, virtualbox, zsh
│   └── themes/                    #   Ambiant-MATE, greeter LightDM, wallpaper
└── home/charlie/                  # configurazione Home Manager dell'utente
    ├── charlie.nix                #   entry point utente
    ├── console/                   #   zsh (grml + starship), zshrc.local
    ├── desktop/                   #   config i3, dconf MATE
    └── programs/git.nix           #   identità git
```

| Modulo | Contenuto principale |
|---|---|
| `modules/core/boot.nix` | GRUB in modalità EFI (`device = "nodev"`, `efiSupport`, `useOSProber`, `enableCryptodisk`), ESP su `/boot` |
| `modules/core/network.nix` | hostname `charlie-lab`, NetworkManager, `nm-applet`, OpenVPN/OpenConnect |
| `modules/core/console.nix` | locale `it_IT.UTF-8`, font console, tool CLI di base |
| `modules/core/time.nix` | fuso `Europe/Rome` |
| `modules/core/xserver.nix` | X11, layout tastiera `it`, `eurosign:e,caps:escape` |
| `modules/core/lightdm.nix` | LightDM + greeter GTK a tema Ambiant-MATE-Dark |
| `modules/core/audio.nix` | PipeWire (ALSA + Pulse + 32 bit) |
| `modules/desktop/mate.nix` | MATE completo + tema Ambiant-MATE compilato dalla repo |
| `modules/desktop/i3wm.nix` | i3 + dmenu, i3status, i3blocks, i3lock |
| `modules/programs/*` | Docker + compose, VirtualBox host, git, zsh di sistema |

## 2. Caratteristiche del sistema installato

- **Firmware:** UEFI (obbligatorio — la configurazione GRUB in repo è EFI-only)
- **Bootloader:** GRUB con ESP montata su `/boot`
- **Filesystem:** root `ext4`, `/boot` `vfat` (ESP), nessuna swap dichiarata
- **Desktop:** X11 + LightDM, con sessioni MATE **e** i3 selezionabili al login
- **Utente:** `charlie` (Stefano Ponzi), shell `zsh`, gruppi `wheel networkmanager audio video storage docker vboxusers`
- **Password:** già presente come `hashedPassword` in `configuration.nix` (vedi §9 per cambiarla)
- **`allowUnfree = true`** — servono per Chrome, VS Code, JetBrains, Discord, Android Studio
- **`system.autoUpgrade.enable = true`** — il sistema si aggiorna da solo sul channel configurato

## 3. Preparare il supporto di installazione

1. Scaricare la ISO **minimal** o **graphical** della versione stabile corrente da <https://nixos.org/download/>.
2. Scriverla su chiavetta:
   ```bash
   sudo dd if=nixos-minimal-XX.XX-x86_64-linux.iso of=/dev/sdX bs=4M status=progress conv=fsync
   ```
3. Avviare da chiavetta in **modalità UEFI** (non Legacy/CSM: la configurazione GRUB in repo presuppone EFI).
4. Verificare la rete (`ip a`); se serve, configurarla con `nmtui`.

> Il layout della ISO è US. Se serve l'italiano: `loadkeys it`.

## 4. Partizionamento e formattazione

Individuare il disco con `lsblk`. Negli esempi seguenti è `/dev/sda`: **sostituirlo con il proprio**.

> [!WARNING]
> I comandi seguenti distruggono tutti i dati sul disco.

```bash
# tabella GPT
parted /dev/sda -- mklabel gpt

# root: dall'inizio del disco (dopo l'ESP) fino a 8 GB dalla fine
parted /dev/sda -- mkpart root ext4 512MB -8GB

# swap (opzionale ma consigliata: nixos-install può essere avido di RAM)
parted /dev/sda -- mkpart swap linux-swap -8GB 100%

# ESP
parted /dev/sda -- mkpart ESP fat32 1MB 512MB
parted /dev/sda -- set 3 esp on
```

Formattazione:

```bash
mkfs.ext4 -L nixos /dev/sda1
mkswap  -L swap  /dev/sda2
mkfs.fat -F 32 -n boot /dev/sda3
```

> [!NOTE]
> 512 MB di ESP sono il minimo comodo. Con `useOSProber` attivo e più generazioni di kernel, 1 GB è più tranquillo.

## 5. Montaggio

```bash
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
swapon /dev/sda2
```

## 6. Clonare la repo e generare l'hardware-configuration

> [!CAUTION]
> **`hardware-configuration.nix` della repo non è riutilizzabile.** Contiene gli UUID dei filesystem della macchina precedente e la riga `virtualisation.virtualbox.guest.enable = true` (era una VM). Va **sempre rigenerato** e sovrascritto.

```bash
# 1. genera la configurazione hardware della macchina corrente
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix /tmp/hardware-configuration.nix

# 2. sostituisci /mnt/etc/nixos con la repo
#    (git è disponibile nella ISO; in caso contrario: nix-shell -p git)
rm -rf /mnt/etc/nixos
git clone <URL-DELLA-REPO> /mnt/etc/nixos

# 3. rimetti l'hardware-configuration appena generato
cp /tmp/hardware-configuration.nix /mnt/etc/nixos/hardware-configuration.nix
```

Controllare che il file generato contenga i mount corretti:

```bash
cat /mnt/etc/nixos/hardware-configuration.nix
```

Devono comparire `fileSystems."/"` (ext4), `fileSystems."/boot"` (vfat) e, se creata, la `swapDevices`.

## 7. Allineare la versione

La versione compare in **cinque** punti. Sostituire ovunque `25.11` con la stabile corrente (es. `26.05`):

| # | Dove | Cosa cambiare |
|---|---|---|
| 1 | ISO scaricata (§3) | `nixos-XX.XX-x86_64-linux.iso` |
| 2 | Channel `nixos` (§8) | `https://nixos.org/channels/nixos-XX.XX` |
| 3 | Channel `home-manager` (§8) | `.../home-manager/archive/release-XX.XX.tar.gz` |
| 4 | `configuration.nix` | `system.stateVersion = "XX.XX";` |
| 5 | `home/charlie/charlie.nix` | `home.stateVersion = "XX.XX";` |

```bash
# comodo, ma controllare sempre il diff prima di installare
cd /mnt/etc/nixos
grep -rn '25\.11' .
sed -i 's/25\.11/26.05/g' configuration.nix home/charlie/charlie.nix
```

> [!IMPORTANT]
> **La versione dei channel e quella di `stateVersion` sono cose diverse.**
> - I **channel** determinano da quale nixpkgs arrivano i pacchetti: vanno tenuti aggiornati.
> - `stateVersion` è un marcatore di compatibilità per i dati su disco (database, formati di configurazione dei servizi). Su **installazione nuova** si imposta alla versione che si sta installando e poi **non si tocca più**, nemmeno dopo un upgrade. Su una macchina già esistente, cambiarlo può rompere i dati applicativi.
>
> Le versioni dei due channel (`nixos` e `home-manager`) devono invece **coincidere fra loro**, altrimenti Home Manager va in errore all'avvio del rebuild.

## 8. Channel (nixos + home-manager)

Questa configurazione **non usa flakes**: `configuration.nix` importa `<home-manager/nixos>`, quindi il channel `home-manager` deve essere registrato **per l'utente root** prima di installare.

```bash
sudo nix-channel --add https://nixos.org/channels/nixos-26.05 nixos
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz home-manager
sudo nix-channel --update
sudo nix-channel --list   # verifica
```

> Se `nixos-install` si lamenta con `file 'home-manager' was not found in the Nix search path`, il channel non è stato registrato come root. In alternativa si può forzare il path:
> ```bash
> nixos-install -I home-manager=https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz
> ```

## 9. Installazione

```bash
nixos-install
```

Al termine viene chiesta la password di **root**.

L'utente `charlie` ha già una `hashedPassword` in `configuration.nix`, quindi non serve `passwd`. Per impostarne una nuova:

```bash
# genera un nuovo hash e incollalo in configuration.nix (users.users.charlie.hashedPassword)
mkpasswd -m sha-512
```

In caso di errore (rete caduta, opzione sbagliata), correggere i file sotto `/mnt/etc/nixos` e rilanciare `nixos-install`: il lavoro già fatto viene riutilizzato.

Infine:

```bash
reboot
```

## 10. Primo avvio e post-installazione

- [ ] **Sessione:** al login LightDM scegliere `MATE` o `i3` dal selettore di sessione.
- [ ] **Rete:** `nmtui` oppure l'applet `nm-applet` in tray.
- [ ] **Docker:** `docker ps` — se dà permission denied, fare logout/login (il gruppo `docker` viene applicato alla nuova sessione).
- [ ] **VirtualBox:** `VBoxManage --version` (l'host è abilitato, l'Extension Pack **no**).
- [ ] **Repo:** la copia in `/etc/nixos` è di root. Per lavorarci come `charlie`:
  ```bash
  sudo chown -R charlie:users /etc/nixos
  ```
- [ ] **Chiave SSH:** `~/.zshrc.local` fa `ssh-add ~/.ssh/azureLeo` all'apertura della shell → ripristinare la chiave privata da backup (non è nella repo, e giustamente).
- [ ] **Dati utente:** ripristinare da backup `~/.ssh`, `~/.m2`, `~/.config`, chiavi GPG, progetti.
- [ ] **Multi-monitor:** la riga `xrandr` in `home/charlie/desktop/i3wm/config` è cablata sul layout della macchina precedente (`eDP-1` + `DP-1` + `DP-3`). Rigenerarla con `arandr` sul nuovo hardware.

## 11. Manutenzione ordinaria

```bash
sudo nixos-rebuild switch              # applica le modifiche a /etc/nixos
sudo nixos-rebuild test                # applica senza renderla generazione di boot
sudo nixos-rebuild boot                # applica al prossimo riavvio
sudo nixos-rebuild switch --rollback   # torna alla generazione precedente

sudo nix-channel --update && sudo nixos-rebuild switch --upgrade   # aggiorna il channel e ricompila

nixos-version                          # versione in esecuzione
nix-collect-garbage -d                 # libera spazio (rimuove le vecchie generazioni)
```

Se una generazione non si avvia, dal menu GRUB si può selezionare una generazione precedente sotto *NixOS — All configurations*.

### Passaggio a una nuova release stabile

```bash
sudo nix-channel --add https://nixos.org/channels/nixos-XX.XX nixos
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-XX.XX.tar.gz home-manager
sudo nix-channel --update
sudo nixos-rebuild switch
```

`system.stateVersion` e `home.stateVersion` **restano quelli dell'installazione originale**: non vanno toccati (vedi §7).

## 12. Note e trappole note

- **`system.autoUpgrade.enable = true`** — il sistema si aggiorna in autonomia sul channel configurato. Comodo, ma significa che un rebuild può partire senza che tu lo abbia chiesto. Disattivarlo se si vuole controllo pieno.
- **`boot.loader.grub.enableCryptodisk = true`** — serve solo se `/boot` sta su un volume LUKS. Con il partizionamento di §4 è inerte: si può lasciare.
- **Path FHS residui** — alcuni file ereditati da una configurazione non-NixOS puntano a percorsi che su NixOS **non esistono**:
  - `home/charlie/console/zsh/zshrc.local`: `JAVA_HOME=/usr/lib/jvm/java-21-openjdk`, `MAVEN_HOME=/usr/share/java/maven`
  - `home/charlie/desktop/i3wm/config`: `/usr/lib/mate-polkit/polkit-mate-authentication-agent-1`, `/opt/Webex/bin/CiscoCollabHost`
  
  Su NixOS conviene sostituirli con riferimenti al Nix store, ad esempio in `home/charlie/console/zsh/zsh.nix`:
  ```nix
  home.sessionVariables.JAVA_HOME = "${pkgs.javaPackages.compiler.openjdk21}/lib/openjdk";
  ```
- **`zshrc.local` non è agganciato** — in `zsh.nix` il blocco `initExtra` che dovrebbe farne il source è commentato (`# zshrc.local TODO`), quindi il file viene installato in `~/.zshrc.local` ma non letto. Da sistemare se se ne vuole l'effetto.
- **Doppia definizione di `programs.zsh`** — una a livello di sistema (`modules/programs/zsh.nix`) e una in Home Manager (`home/charlie/console/zsh/zsh.nix`). Non è un errore, ma le due usano attributi con nomi diversi (`autosuggestions` vs `autosuggestion`, `ohMyZsh` vs `oh-my-zsh`): attenzione quando si modifica una delle due.
- **Segreti** — vedi [§13](#13-segreti).
- **Documentazione** — `nixos-help` apre il manuale locale; le opzioni si cercano su <https://search.nixos.org/options>.

## 13. Segreti

Nella repo non c'è nessun segreto: né hash di password, né l'indirizzo email aziendale. Entrambi vivono in file **fuori dal versionamento**, che vanno creati a mano.

Un hook pre-commit (`.githooks/pre-commit`) blocca il commit se fra le righe aggiunte ricompare un hash Unix (`$6$`, `$y$`, `$2b$`) o il dominio aziendale. Si attiva con:

```bash
git config core.hooksPath .githooks
```

`nix develop` lo fa da solo e mette `gitleaks` nel PATH. Senza gitleaks l'hook usa un controllo `grep` equivalente. Bypass di emergenza: `git commit --no-verify`.

### 13.1 Password di sistema — DA FARE PRIMA DEL PRIMO SWITCH

> [!CAUTION]
> La configurazione usa `users.users.charlie.hashedPasswordFile` e `users.mutableUsers = false`.
> Se il file **non esiste al momento dello `switch`**, l'account `charlie` resta senza password valida: niente login grafico, niente `sudo`, e `passwd` non funziona più perché `mutableUsers = false` rende `/etc/shadow` di sola lettura.
> Creare i file **prima** di applicare la configurazione.

I percorsi attesi sono:

| File | Utente |
|---|---|
| `/etc/secrets/charlie.hashedPassword` | `charlie` |
| `/etc/secrets/root.hashedPassword` | `root` (via di rientro se il primo è sbagliato) |

Procedura, da eseguire come root:

```bash
# 1. cartella dei segreti, leggibile solo da root
sudo install -d -m 0700 /etc/secrets

# 2. hash per charlie — mkpasswd chiede la password due volte
#    (se manca il comando: nix shell nixpkgs#mkpasswd)
mkpasswd -m sha-512 | sudo tee /etc/secrets/charlie.hashedPassword

# 3. hash per root, diverso da quello di charlie
mkpasswd -m sha-512 | sudo tee /etc/secrets/root.hashedPassword

# 4. permessi stretti
sudo chmod 0600 /etc/secrets/*.hashedPassword

# 5. verifica: una riga sola, che inizia con $6$
sudo cat /etc/secrets/charlie.hashedPassword
```

> [!IMPORTANT]
> Il file deve contenere **solo l'hash**, su una riga. `mkpasswd` non aggiunge nulla, ma se l'hash viene incollato a mano attenzione a non lasciarci spazi o righe vuote.

**In fase di installazione da zero** i file vanno creati sotto `/mnt` prima di `nixos-install`:

```bash
install -d -m 0700 /mnt/etc/secrets
mkpasswd -m sha-512 > /mnt/etc/secrets/charlie.hashedPassword
mkpasswd -m sha-512 > /mnt/etc/secrets/root.hashedPassword
chmod 0600 /mnt/etc/secrets/*.hashedPassword
```

**Per cambiare password in seguito** non si usa `passwd`:

```bash
mkpasswd -m sha-512 | sudo tee /etc/secrets/charlie.hashedPassword
sudo nixos-rebuild switch --flake .#charlie-lab
```

**Se ci si è chiusi fuori:** al menu GRUB scegliere una generazione precedente (quella prima dello switch), oppure premere `e` sulla voce di boot e aggiungere `init=/bin/sh` alla riga del kernel per ottenere una shell di root senza password, montare `/` in lettura-scrittura e creare i file.

`/etc/secrets/` non è gestito da NixOS: sopravvive ai rebuild, ma **non è nella repo**. Va nel backup insieme a `~/.ssh` e agli altri dati non versionati.

### 13.2 Identità git

`home/charlie/programs/git.nix` imposta come identità di default quella **personale**, e usa `includeIf` per quella aziendale:

| Percorso | Identità |
|---|---|
| ovunque | personale (default) |
| `~/Progetti/**` | aziendale |
| `~/Progetti/personali/**` | personale (torna al default) |

Git applica gli include in ordine e l'ultimo che corrisponde vince, quindi la sottocartella `personali/` sovrascrive la regola più larga. Non serve riorganizzare le cartelle esistenti.

Il file con l'identità aziendale **non è nella repo** e va creato a mano una volta sola:

```bash
mkdir -p ~/.config/git
cat > ~/.config/git/identita-lavoro <<'EOF'
[user]
	name = Stefano Ponzi
	email = nome.cognome@azienda.example
EOF
```

Se il file non esiste git lo ignora in silenzio e resta valida l'identità personale.

Verifica, da dentro un repo di lavoro e uno personale:

```bash
git -C ~/Progetti/SVO config user.email             # → aziendale
git -C ~/Progetti/personali/nixos config user.email # → personale
```

Il file `~/.config/git/identita-personale` lo genera Home Manager e non va toccato a mano.
