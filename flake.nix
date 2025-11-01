{
  description = "Fully reproducible NixOS + Home Manager dotfiles";

  inputs = {
    mac-style-plymouth = {
      url = "github:SergioRibera/s4rchiso-plymouth-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager release matching NixOS 25.05
    # NUR (Nix User Repository)
    nur.url = "github:nix-community/NUR";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ...
    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ...
  };
  outputs = { self, nixpkgs, home-manager, nur, ... }@inputs:
    let
        system = "x86_64-linux";

        pkgs = import nixpkgs {
            system = system;
            overlays = [
                nur.overlay
                inputs.mac-style-plymouth.overlays.default
            ];
        };

        lib = pkgs.lib;

        specialArgs = {
            inherit system inputs nur pkgs;
        };

        extraSpecialArgs = specialArgs;
    in {
        nixosConfigurations = {
            hp = lib.nixosSystem {
                inherit system specialArgs;
                modules = [
                    ./hosts/hp/configuration.nix
                    ./hosts/hp/hardware-configuration.nix
                    nur.modules.nixos.default
                    home-manager.nixosModules.home-manager {
                        home-manager = {
                            inherit extraSpecialArgs;
                            useGlobalPkgs = true;
                            useUserPackages = true;
                            users.mrn1 = import ./hosts/hp/home.nix;
                        };
                    }
                ];
            };
        };
    }
