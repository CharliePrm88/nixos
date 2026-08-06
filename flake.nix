{
  description = "Configurazione NixOS di charlie-lab (sistema + Home Manager)";

  inputs = {
    # nixos-unstable: si vuole sempre l'ultima versione dei pacchetti,
    # non una release fissata. Gli aggiornamenti si fanno a mano con
    # `nix flake update` (vedi modules/core/nix.nix).
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      # Il branch master di home-manager segue nixos-unstable.
      url = "github:nix-community/home-manager";
      # Un solo nixpkgs per sistema e Home Manager: evita di scaricare
      # e valutare due alberi diversi.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.charlie-lab = nixpkgs.lib.nixosSystem {
        # Niente `system` qui: la piattaforma arriva da
        # nixpkgs.hostPlatform in hardware-configuration.nix.
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
        ];
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;

      # `nix develop` per lavorare sulla repo: strumenti di lint e
      # formattazione, piu' l'attivazione dell'hook pre-commit.
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          deadnix
          gitleaks
          nixfmt-rfc-style
          statix
        ];
        shellHook = ''
          git config core.hooksPath .githooks
        '';
      };
    };
}
