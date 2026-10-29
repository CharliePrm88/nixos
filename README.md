# nixos

Configurazione NixOS dichiarativa, a flake, di **`charlie-lab`** — sistema + [Home Manager](https://github.com/nix-community/home-manager).

L'obiettivo è poter ricostruire la macchina da zero **clonando solo questa repo**: niente canali da registrare a mano, niente file da recuperare altrove. Le uniche eccezioni sono i segreti, che per definizione non stanno qui e sono elencati in [§8](#8-segreti).

---

## Indice

1. [Layout della repo](#1-layout-della-repo)
2. [Prerequisiti](#2-prerequisiti)
3. [Layout dei dischi](#3-layout-dei-dischi)
4. [Installazione da zero](#4-installazione-da-zero)
5. [Lavorare sulla configurazione](#5-lavorare-sulla-configurazione)
6. [Aggiornare il sistema](#6-aggiornare-il-sistema)
7. [Rollback](#7-rollback)
8. [Segreti](#8-segreti)
9. [Aggiungere un host](#9-aggiungere-un-host)
10. [Trappole note](#10-trappole-note)

---

## 1. Layout della repo

```
.
├── flake.nix                      # inputs, nixosConfigurations, formatter, devShell
├── flake.lock                     # revisioni esatte di nixpkgs e home-manager
├── hosts/
│   ├── charlie-lab/               # la VM VirtualBox
│   │   ├── default.nix            #   hostname, account, stateVersion
│   │   └── hardware-configuration.nix  # UUID dei filesystem — per-macchina
│   └── charlie-desktop/           # segnaposto per il futuro bare metal
├── modules/                       # configurazione di sistema, condivisa fra host
│   ├── core.nix                   #   → audio, boot, console, lightdm, network, nix, security, time, xserver
│   ├── desktop.nix                #   → i3wm, mate
│   ├── qol.nix                    #   zram, sessione, keyring, stampa, bluetooth, fwupd
│   ├── fonts/, packages.nix, programs.nix
│   └── themes/                    #   Ambiant-MATE, greeter LightDM, wallpaper
├── home/charlie/                  # configurazione Home Manager dell'utente
├── scripts/valida.sh              # flake check + build + statix + deadnix + nixfmt
├── .githooks/pre-commit           # blocca il reingresso di segreti
└── .gitleaks.toml
```

La regola di divisione è una sola:

> **`hosts/` contiene ciò che cambia da macchina a macchina** (hardware, hostname, UUID, `stateVersion`).
> **`modules/` è condiviso** e non contiene hostname, UUID né riferimenti al guest VirtualBox.

| Modulo | Contenuto |
|---|---|
| `modules/core/boot.nix` | GRUB in modalità EFI (`device = "nodev"`, `efiSupport`, `useOSProber`), ESP su `/boot`, max 20 generazioni nel menu |
| `modules/core/nix.nix` | `experimental-features`, `allowUnfree`, GC settimanale, `optimise`, `autoUpgrade` disattivato |
| `modules/core/security.nix` | `sudo` con password, `users.mutableUsers = false` |
| `modules/core/network.nix` | NetworkManager, `nm-applet`, OpenVPN/OpenConnect |
| `modules/core/console.nix` | locale `it_IT.UTF-8`, font console, tool CLI di base |
| `modules/core/xserver.nix` | X11, layout tastiera `it`, `eurosign:e,caps:escape` |
| `modules/core/lightdm.nix` | LightDM + greeter GTK a tema Ambiant-MATE-Dark |
| `modules/core/audio.nix` | PipeWire (ALSA + Pulse + 32 bit) |
| `modules/desktop/mate.nix` | MATE completo, gvfs, tema Ambiant-MATE costruito dalla repo |
| `modules/desktop/i3wm.nix` | i3 + dmenu, i3status, i3blocks, i3lock |
| `modules/qol.nix` | zram, sessione predefinita MATE, gnome-keyring, AppImage, CUPS + Avahi, Bluetooth, fwupd, prune di Docker |
| `modules/programs/` | Docker + compose, VirtualBox host, git, zsh, JDK 21, nix-ld |

## 2. Prerequisiti

- **Firmware UEFI.** La configurazione GRUB in repo è EFI-only: avviare la ISO in modalità UEFI, non Legacy/CSM.
- **ISO NixOS**, minimal o graphical, da <https://nixos.org/download/>. Va bene qualsiasi versione recente: serve solo a installare, i pacchetti arrivano dal flake.
  ```bash
  sudo dd if=nixos-minimal-XX.XX-x86_64-linux.iso of=/dev/sdX bs=4M status=progress conv=fsync
  ```
- **Rete funzionante** nella ISO (`ip a`; se serve, `nmtui`).
- Layout tastiera: la ISO parte in US. Per l'italiano: `loadkeys it`.

> [!NOTE]
> **Non serve registrare nessun canale.** Questa configurazione è un flake: `nixpkgs` e `home-manager` sono dichiarati in `flake.nix` e bloccati a una revisione esatta in `flake.lock`. Il vecchio `nix-channel --add` non c'entra più niente.

## 3. Layout dei dischi

Individuare il disco con `lsblk`. Negli esempi è `/dev/sda`: **sostituirlo con il proprio.**

> [!WARNING]
> I comandi seguenti distruggono tutti i dati sul disco.

| Partizione | Tipo | Dimensione | Mount |
|---|---|---|---|
| `/dev/sda1` | ext4, label `nixos` | tutto il resto | `/` |
| `/dev/sda2` | linux-swap, label `swap` | 8 GB | swap |
| `/dev/sda3` | fat32, label `boot`, flag `esp` | 512 MB (1 GB se c'è spazio) | `/boot` |

```bash
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart root ext4 512MB -8GB
parted /dev/sda -- mkpart swap linux-swap -8GB 100%
parted /dev/sda -- mkpart ESP fat32 1MB 512MB
parted /dev/sda -- set 3 esp on

mkfs.ext4 -L nixos /dev/sda1
mkswap    -L swap  /dev/sda2
mkfs.fat -F 32 -n boot /dev/sda3
```

Montaggio:

```bash
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
swapon /dev/sda2
```

> [!NOTE]
> La swap è consigliata anche con `zramSwap` attivo (`modules/qol.nix`): `nixos-install` può essere avido di RAM, e zram non aiuta quando serve memoria vera.
> 512 MB di ESP sono il minimo comodo. Con `useOSProber` e 20 generazioni nel menu, 1 GB è più tranquillo.

## 4. Installazione da zero

### 4.1 Clonare la repo

```bash
nix-shell -p git          # se git non è nella ISO
git clone https://github.com/CharliePrm88/nixos.git /mnt/etc/nixos
cd /mnt/etc/nixos
```

### 4.2 Generare l'hardware-configuration

> [!CAUTION]
> **`hosts/charlie-lab/hardware-configuration.nix` non è riutilizzabile su un'altra macchina.** Contiene gli UUID dei filesystem della VM e `virtualisation.virtualbox.guest.enable`. Va rigenerato e sovrascritto.

```bash
nixos-generate-config --root /mnt --show-hardware-config \
  > /mnt/etc/nixos/hosts/charlie-lab/hardware-configuration.nix
```

Controllare che contenga `fileSystems."/"` (ext4), `fileSystems."/boot"` (vfat) e, se creata, `swapDevices`. Se si installa su hardware reale e non su una VM, togliere la riga `virtualisation.virtualbox.guest.enable`.

### 4.3 Creare i file delle password

> [!CAUTION]
> **Da fare prima di `nixos-install`, non dopo.** La configurazione usa `hashedPasswordFile` e `users.mutableUsers = false`: senza questi file l'account resta senza password valida e `passwd` non funziona. Dettagli e vie d'uscita in [§8](#8-segreti).

```bash
install -d -m 0700 /mnt/etc/secrets
mkpasswd -m sha-512 > /mnt/etc/secrets/charlie.hashedPassword
mkpasswd -m sha-512 > /mnt/etc/secrets/root.hashedPassword
chmod 0600 /mnt/etc/secrets/*.hashedPassword
```

### 4.4 Installare

```bash
git add -A                  # il flake vede solo i file tracciati da git
nixos-install --flake /mnt/etc/nixos#charlie-lab
reboot
```

> [!IMPORTANT]
> **`git add` non è opzionale.** Un flake legge solo i file tracciati da git. Un `hardware-configuration.nix` appena scritto e non aggiunto risulta *inesistente*, e l'errore che ne esce non lo dice chiaramente.

`nixos-install` chiede la password di root a fine installazione: con `mutableUsers = false` quella richiesta è ininfluente, vale il file di §4.3.

### 4.5 Dopo il primo avvio

- [ ] **Sessione:** LightDM parte su MATE (`services.displayManager.defaultSession`). i3 si sceglie dal selettore di sessione.
- [ ] **Rete:** `nmtui` o l'applet in tray.
- [ ] **Docker:** `docker ps`. Se dà permission denied, fare logout/login.
- [ ] **Repo:** la copia in `/etc/nixos` è di root:
      ```bash
      sudo chown -R charlie:users /etc/nixos
      ```
- [ ] **Identità git aziendale:** creare `~/.config/git/identita-lavoro` — vedi [§8.2](#82-identità-git).
- [ ] **Chiavi SSH:** ripristinare `~/.ssh` da backup. L'agent è attivo (`services.ssh-agent`) ma non carica niente da solo: `ssh-add ~/.ssh/<chiave>`, oppure `AddKeysToAgent yes` in `~/.ssh/config`.
- [ ] **Dati utente:** `~/.m2`, `~/.config`, chiavi GPG, progetti.
- [ ] **Multi-monitor:** la riga `xrandr` in `home/charlie/desktop/i3wm/config` è cablata su `eDP-1` + `DP-1` + `DP-3`. Rigenerarla con `arandr`.

## 5. Lavorare sulla configurazione

```bash
cd /etc/nixos          # oppure dove tieni il clone
nix develop            # gitleaks, statix, deadnix, nixfmt + attivazione dell'hook
```

| Comando | Cosa fa |
|---|---|
| `sudo nixos-rebuild switch --flake .#charlie-lab` | applica adesso e imposta come generazione di boot |
| `sudo nixos-rebuild test --flake .#charlie-lab` | applica adesso, **non** tocca il bootloader |
| `sudo nixos-rebuild boot --flake .#charlie-lab` | applica al prossimo riavvio |
| `nixos-rebuild build --flake .#charlie-lab` | costruisce e basta, senza root |
| `nixos-rebuild build-vm --flake .#charlie-lab` | costruisce una VM di prova: `./result/bin/run-*-vm` |
| `./scripts/valida.sh` | flake check + build + build-vm + statix + deadnix + nixfmt |
| `nix fmt` | riformatta tutti i `.nix` |

`test` è la rete di sicurezza per le modifiche rischiose: se qualcosa va storto, un riavvio riporta alla generazione precedente perché il bootloader non è stato toccato.

> [!IMPORTANT]
> Ogni file `.nix` nuovo va `git add`-ato **prima** di qualsiasi build.

## 6. Aggiornare il sistema

`system.autoUpgrade` è **disattivato di proposito** (il perché è scritto in `modules/core/nix.nix`): su `nixos-unstable` un rebuild non sorvegliato può lasciare il desktop rotto, e non aggiornerebbe comunque `flake.lock` nella repo.

```bash
nix flake update                              # aggiorna nixpkgs e home-manager in flake.lock
nixos-rebuild build --flake .#charlie-lab     # prova a costruire, senza applicare
sudo nixos-rebuild switch --flake .#charlie-lab
git commit flake.lock -m "Aggiorna flake.lock"   # solo se tutto funziona
```

Per aggiornare un solo input: `nix flake update nixpkgs`.

**`system.stateVersion` e `home.stateVersion` restano `25.11` per sempre.** Non sono la versione dei pacchetti — quella dipende solo da `flake.lock` — ma un marcatore di compatibilità per i dati su disco. Cambiarli su una macchina esistente può rompere i dati applicativi.

La manutenzione dello store è automatica: garbage collection settimanale con `--delete-older-than 30d` e deduplica per hard link. Per farla subito:

```bash
sudo nix-collect-garbage --delete-older-than 30d
sudo nix store optimise
```

## 7. Rollback

**Dal sistema avviato**, alla generazione precedente:

```bash
sudo nixos-rebuild switch --rollback
```

**A una generazione specifica:**

```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
sudo nix-env --switch-generation 42 --profile /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

**Se il sistema non si avvia:** dal menu GRUB, sotto *NixOS — All configurations*, scegliere una generazione precedente. Il menu ne tiene 20 (`boot.loader.grub.configurationLimit`).

**Se ci si è chiusi fuori per via delle password:** vedi [§8.1](#81-password-di-sistema).

**Per tornare a una revisione precedente dei pacchetti**, non del sistema: `git checkout` del vecchio `flake.lock` e rebuild. È il motivo per cui il lock va committato.

## 8. Segreti

Nella repo **non c'è nessun segreto**: né hash di password, né l'indirizzo email aziendale. Vivono in file fuori dal versionamento, da creare a mano.

| Cosa | Dove | Chi lo crea |
|---|---|---|
| Hash password di `charlie` | `/etc/secrets/charlie.hashedPassword` | a mano, vedi §8.1 |
| Hash password di `root` | `/etc/secrets/root.hashedPassword` | a mano, vedi §8.1 |
| Identità git aziendale | `~/.config/git/identita-lavoro` | a mano, vedi §8.2 |
| Identità git personale | `~/.config/git/identita-personale` | Home Manager |
| Token HTTPS di git | `~/.git-credentials` | da backup (`credential.helper = store`) |
| Chiavi SSH | `~/.ssh/` | da backup |
| Chiavi GPG | `~/.gnupg/` | da backup |
| Chiavi WireGuard | `~/.config/wireguard/` | da backup |
| Token Telegram di intruder-watch | `~/.config/intruder-watch/env` | a mano, vedi `home/charlie/programs/intruder-watch.nix` |
| Profili Wi-Fi/VPN | `/etc/NetworkManager/system-connections/` | da backup, vedi §8.3 |

Nessuno di questi è gestito da NixOS: sopravvivono ai rebuild ma **vanno nel backup**, perché non sono nella repo.

Un hook pre-commit (`.githooks/pre-commit`) blocca il commit se fra le righe aggiunte ricompare un hash Unix (`$6$`, `$y$`, `$2b$`) o il dominio aziendale. Si attiva con `git config core.hooksPath .githooks`; `nix develop` lo fa da solo. Senza `gitleaks` installato l'hook usa un controllo `grep` equivalente, quindi funziona anche fuori da Nix. Bypass di emergenza: `git commit --no-verify`.

### 8.1 Password di sistema

> [!CAUTION]
> `users.users.charlie.hashedPasswordFile` + `users.mutableUsers = false`.
> Se il file **non esiste al momento dello `switch`**, l'account resta senza password valida: niente login grafico, niente `sudo`, e `passwd` non funziona perché `mutableUsers = false` rende `/etc/shadow` di sola lettura.

**Creazione** (i file devono contenere solo l'hash, su una riga):

```bash
sudo install -d -m 0700 /etc/secrets
mkpasswd -m sha-512 | sudo tee /etc/secrets/charlie.hashedPassword
mkpasswd -m sha-512 | sudo tee /etc/secrets/root.hashedPassword
sudo chmod 0600 /etc/secrets/*.hashedPassword
sudo cat /etc/secrets/charlie.hashedPassword     # verifica: una riga, inizia con $6$
```

Se `mkpasswd` non c'è: `nix shell nixpkgs#mkpasswd`.

**Cambiare password** (non si usa `passwd`):

```bash
mkpasswd -m sha-512 | sudo tee /etc/secrets/charlie.hashedPassword
sudo nixos-rebuild switch --flake .#charlie-lab
```

**Se ci si è chiusi fuori**, in ordine di preferenza:

1. Password di root: `Ctrl+Alt+F2` per una TTY, login come `root`, sistemare il file, `nixos-rebuild switch`. È esattamente perché serve questa via di rientro che `root.hashedPasswordFile` è dichiarato.
2. Menu GRUB → *All configurations* → la generazione precedente allo switch.
3. Al menu GRUB premere `e`, aggiungere `init=/bin/sh` alla riga del kernel, `Ctrl+X`. Si ottiene una shell di root senza password:
   ```sh
   mount -o remount,rw /
   mkdir -p /etc/secrets
   # incollare un hash generato altrove
   echo '$6$...' > /etc/secrets/charlie.hashedPassword
   chmod 0600 /etc/secrets/charlie.hashedPassword
   /nix/var/nix/profiles/system/bin/switch-to-configuration switch
   reboot -f
   ```

### 8.2 Identità git

`home/charlie/programs/git.nix` usa come default l'identità **personale** e passa a quella aziendale con `includeIf`:

| Percorso del repo | Identità |
|---|---|
| ovunque | personale (default) |
| `~/Progetti/**` | aziendale |
| `~/Progetti/personali/**` | personale (torna al default) |

Git applica gli `include` in ordine e **l'ultimo che corrisponde vince**: la regola sulla sottocartella `personali/` sovrascrive quella più larga. Così non serve riorganizzare le cartelle esistenti.

Il file con l'identità aziendale non è nella repo e va creato una volta sola:

```bash
mkdir -p ~/.config/git
cat > ~/.config/git/identita-lavoro <<'EOF'
[user]
	name = Stefano Ponzi
	email = nome.cognome@azienda.example
EOF
```

Se non esiste, git lo ignora in silenzio e resta valida l'identità personale. Verifica:

```bash
git -C ~/Progetti/SVO config user.email               # → aziendale
git -C ~/Progetti/personali/nixos config user.email   # → personale
```

`~/.config/git/identita-personale` lo genera Home Manager: non va modificato a mano.

### 8.3 Profili NetworkManager

I profili Wi-Fi e VPN contengono le password in chiaro: non stanno nella repo ma in `/etc/NetworkManager/system-connections/`, che NetworkManager gestisce da sé anche su NixOS. Per ripristinarli da un backup:

```bash
sudo install -m 0600 -o root -g root /percorso/backup/*.nmconnection /etc/NetworkManager/system-connections/
sudo nmcli connection reload
```

Togliere prima eventuali `interface-name=wlan0`: su NixOS la scheda Wi-Fi ha un nome stabile (`wlp…`) e un profilo legato a `wlan0` non si attiva mai. I certificati della VPN OpenVPN stanno in `~/.local/share/networkmanagement/certificates/`.

### 8.4 Chiavi Secure Boot

Come su Arch, il Secure Boot usa chiavi proprie gestite da `sbctl`, senza shim. Le chiavi stanno in `/var/lib/sbctl`, fuori dalla repo: la chiave privata `db.key` permette di firmare qualunque cosa il firmware accetterà, quindi non va mai copiata nella repo. Conviene invece tenerne un backup cifrato: se si perdono, per firmare di nuovo bisogna rifare tutta la procedura, BIOS compreso.

Ogni `nixos-rebuild switch` firma `grubx64.efi` e i kernel in `/boot/kernels` (`extraInstallCommands` in `modules/core/boot.nix`). Senza chiavi la firma viene saltata con un avviso. Gli initrd non sono firmati, come su Arch.

Procedura iniziale, o dopo aver perso le chiavi:

```bash
# 1. Secure Boot ancora spento. Creare le chiavi e fare il rebuild:
#    GRUB viene reinstallato con i moduli inclusi e firmato insieme ai kernel.
sudo sbctl create-keys
sudo nixos-rebuild switch --flake /etc/nixos#charlie-lab
sudo sbctl verify          # grubx64.efi e i *-bzImage devono risultare firmati

# 2. Riavviare e controllare che NixOS e Windows partano ancora da GRUB.

# 3. Nel BIOS: cancellare le chiavi / entrare in Setup Mode. Riavviare in NixOS:
sudo sbctl status          # Setup Mode: Enabled
sudo sbctl enroll-keys --microsoft

# 4. Nel BIOS: attivare il Secure Boot. Dopo l'avvio:
sudo sbctl status          # Secure Boot: Enabled
```

`--microsoft` è obbligatorio: senza le chiavi Microsoft Windows non si avvia più, e su alcune schede nemmeno le option ROM della GPU. Se Windows usa BitLocker, al primo avvio dopo il cambio di chiavi chiederà la recovery key: sospendere BitLocker prima del passo 3, o tenere la chiave a portata di mano.

Se dopo il passo 4 GRUB dà `prohibited by secure boot policy` su un modulo, quel modulo manca dalla lista `--modules` in `modules/core/boot.nix`: aggiungerlo, disattivare il Secure Boot, fare il rebuild, riattivarlo.

## 9. Aggiungere un host

Vedi `hosts/charlie-desktop/README.md`, che è il segnaposto documentato per il futuro bare metal. In sintesi: generare l'`hardware-configuration.nix` sulla macchina di destinazione, scrivere un `default.nix` sul modello di `charlie-lab`, registrare `nixosConfigurations.<nome>` in `flake.nix`, `git add`.

`modules/` non va toccato: è già privo di hostname, UUID e riferimenti al guest VirtualBox.

## 10. Trappole note

- **`git add` prima di ogni build.** Il flake ignora i file non tracciati. È la causa più comune di errori incomprensibili.
- **`nixos-rebuild switch` va sempre lanciato con `--flake .#charlie-lab`.** Senza, `nixos-rebuild` cerca `/etc/nixos/configuration.nix`, che non esiste più.
- **`boot.loader.grub.enableCryptodisk = true`** serve solo se `/boot` sta su un volume LUKS. Con il partizionamento di §3 è inerte: si può lasciare.
- **Path FHS in `home/charlie/desktop/i3wm/config`:** il file è quello di Arch, invariato. `/usr/lib/mate-polkit/…` e `/opt/Webex/…` vengono sostituiti con i percorsi nello store da `i3wm.nix` (`builtins.replaceStrings`): se si aggiungono altri path FHS al file, vanno aggiunti anche lì.
- **App fuori da nixpkgs** (`home/charlie/programs/opt-apps.nix`): SQL Developer e AsciidocFX stanno in `~/.local/opt/`, copiati dal vecchio `/opt` di Arch. Nix dichiara solo lanciatori e voci di menu: i file vanno nel backup.
- **`xdg.mimeApps`** rende `~/.config/mimeapps.list` di sola lettura: le associazioni si cambiano in `home/charlie/desktop/mime.nix`, non dalle finestre "Apri con".
- **Il tema Ambiant-MATE** viene costruito da `modules/themes/mate` e installa solo `themes/` e `icons/`. Le due cartelle `gtksourceview-*` sono nella repo ma non finiscono nel pacchetto.
- **`hardware.bluetooth` e `services.fwupd`** sono attivi ma inerti su una VM VirtualBox. Servono al futuro host bare metal.
- **Storia git riscritta.** I segreti sono stati rimossi da tutta la storia con `git filter-repo`, ma su GitHub il ref `refs/pull/1/head` non è cancellabile con un force push: i vecchi commit restano raggiungibili per SHA diretto. La password è stata cambiata, quindi l'hash non è più valido.
- **Documentazione:** `nixos-help` per il manuale locale, <https://search.nixos.org/options> per le opzioni, `man home-configuration.nix` per quelle di Home Manager.
