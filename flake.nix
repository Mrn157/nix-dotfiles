{
  description = "Fully reproducible NixOS + Home Manager dotfiles";
  inputs = {
  # Plymouth (Kept so I can remember)
  #inputs = {
  #  mac-style-plymouth = {
  #     url = "github:SergioRibera/s4rchiso-plymouth-theme";
  #      inputs.nixpkgs.follows = "nixpkgs";
  #  };

    # Home Manager release matching NixOS 25.05
    # NUR (Nix User Repository)
    nur.url = "github:nix-community/NUR";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ...
    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
    inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, nur, nixpkgs-unstable, ... }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
      lib-unstable = nixpkgs-unstable.lib;
      extraSpecialArgs = { inherit system inputs nur pkgs; };  # <- passing inputs to the attribute set for home-manager
      specialArgs = { inherit system inputs nur pkgs-unstable; };       # <- passing inputs to the attribute set for NixOS (optional)
    in {
    nixosConfigurations = {
      # hp is hostname
      # To change system to use unstable as default, use hp = lib.unstable.nixosSystem {
      hp = lib.nixosSystem {
        modules = [
          ./hosts/hp/configuration.nix
          ./hosts/hp/hardware-configuration.nix
	        # NUR module
          nur.modules.nixos.default
          # Overlay to restore pkgs.nur.repos.… namespace
          { nixpkgs.overlays = [ nur.overlays.default ]; }
          # Plymouth (Kept so I can remember)
          # { nixpkgs.overlays = [ inputs.mac-style-plymouth.overlays.default ]; }
          home-manager.nixosModules.home-manager {
            home-manager = {
              inherit extraSpecialArgs;
              useGlobalPkgs = true;
              useUserPackages = true;
              users.mrn1 = import ./hosts/hp/home.nix;
            };
          }
        ];
        inherit specialArgs;
      };
      hp-dwl = lib-unstable.nixosSystem {
        modules = [
          ./hosts/hp-dwl/configuration.nix
          ./hosts/hp-dwl/hardware-configuration.nix
	        # NUR module
          nur.modules.nixos.default
          # Overlay to restore pkgs.nur.repos.… namespace
          { nixpkgs.overlays = [ nur.overlays.default ]; }
          # Plymouth (Kept so I can remember)
          # { nixpkgs.overlays = [ inputs.mac-style-plymouth.overlays.default ]; }
          home-manager.nixosModules.home-manager {
            home-manager = {
              inherit extraSpecialArgs;
              useGlobalPkgs = true;
              useUserPackages = true;
              users.mrn1 = import ./hosts/hp-dwl/home.nix;
            };
          }
        ];
      };
    };
  };
}
