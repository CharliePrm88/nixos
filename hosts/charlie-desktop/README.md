# charlie-desktop — segnaposto

Cartella predisposta per il futuro host **bare metal**. Al momento è
volutamente vuota: non esiste ancora un `default.nix`, e il flake **non**
definisce `nixosConfigurations.charlie-desktop`. Aggiungere una
configurazione incompleta romperebbe `nix flake check`.

## Come popolarla

1. **Generare l'hardware-configuration sulla macchina di destinazione.**
   Dalla ISO di installazione, dopo aver montato i filesystem su `/mnt`:

   ```bash
   nixos-generate-config --root /mnt --no-filesystems   # se i mount sono già dichiarati altrove
   nixos-generate-config --root /mnt                    # caso normale
   cp /mnt/etc/nixos/hardware-configuration.nix hosts/charlie-desktop/
   ```

   Il file contiene gli UUID dei filesystem di *quella* macchina: non è
   riutilizzabile da `charlie-lab` e non va mai copiato fra host.

2. **Scrivere `hosts/charlie-desktop/default.nix`.** Partire da
   `../charlie-lab/default.nix` e cambiare solo ciò che è per-host:

   - `networking.hostName = "charlie-desktop";`
   - `system.stateVersion` = la versione con cui si installa **quella**
     macchina, non quella di `charlie-lab`
   - `users.users.charlie.extraGroups`: togliere `vboxusers` se non serve
   - eventuali moduli in più (driver GPU, `hardware.cpu.*.updateMicrocode`,
     `services.xserver.videoDrivers`)

   Gli import di `../../modules/*` restano identici: `modules/` è
   deliberatamente privo di hostname, UUID e riferimenti al guest
   VirtualBox, quindi è condivisibile fra host senza modifiche.

3. **Registrare l'host nel flake**, in `flake.nix`:

   ```nix
   nixosConfigurations.charlie-desktop = nixpkgs.lib.nixosSystem {
     specialArgs = { inherit inputs; };
     modules = [
       ./hosts/charlie-desktop
       home-manager.nixosModules.home-manager
     ];
   };
   ```

4. **`git add` di tutti i file nuovi** prima di qualsiasi build: il flake
   vede solo ciò che è tracciato da git.

5. Costruire senza applicare:

   ```bash
   nixos-rebuild build --flake .#charlie-desktop
   ```

## Da rivedere per il bare metal

Cose che su `charlie-lab` vanno bene perché è una VM, ma che su hardware
reale vanno riconsiderate:

- **Bootloader.** `modules/core/boot.nix` usa GRUB in modalità EFI. Il
  passaggio a systemd-boot + lanzaboote (Secure Boot / TPM2) è fuori
  dallo scopo del refactor corrente ed è tracciato a parte.
- **VirtualBox.** `modules/programs/virtualbox.nix` abilita l'*host*
  VirtualBox. La sostituzione con libvirtd è tracciata a parte.
- **Layout monitor.** `home/charlie/desktop/i3wm/config` contiene una riga
  `xrandr` cablata su `eDP-1` + `DP-1` + `DP-3`. Rigenerarla con `arandr`.
- **Microcodice e firmware.** `hardware.cpu.intel.updateMicrocode` o
  `hardware.cpu.amd.updateMicrocode` a seconda della CPU.
