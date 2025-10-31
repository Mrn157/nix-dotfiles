{
  description = "Fully reproducible NixOS + Home Manager dotfiles";

  inputs = {
    # Stable NixOS release
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Home Manager release matching NixOS 25.05
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # NUR (Nix User Repository)
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager";
    };
    # ...
    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
    };
    # ...
  };

  outputs = { self, nixpkgs, home-manager, nur, ... }:
    {
      nixosConfigurations = {
        hp = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          # Pass nur to modules
          specialArgs = { inherit nur; };

          modules = [
            ./hosts/hp/configuration.nix
            ./hosts/hp/hardware-configuration.nix

            # Home Manager as a NixOS module
            home-manager.nixosModules.home-manager

            # NUR module
            nur.modules.nixos.default

            # Overlay to restore pkgs.nur.repos.… namespace
            { nixpkgs.overlays = [ nur.overlay ]; }

            # Per-host user config
            { home-manager.users.mrn1 = import ./hosts/hp/home.nix; }
          ];
        };
      };
    };
}
