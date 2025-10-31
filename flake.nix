{
  description = "Fully reproducible NixOS + Home Manager dotfiles";

  inputs = {

    # Home Manager release matching NixOS 25.05
    # NUR (Nix User Repository)
    nur.url = "github:nix-community/NUR";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ...
    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
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
