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
  outputs = { self, nixpkgs, home-manager, nur, mac-style-plymouth, ... }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        system = system;
        overlays = [
          nur.overlay
          mac-style-plymouth.overlays.default
        ];
      };
      lib = nixpkgs.lib;
      extraSpecialArgs = { inherit system inputs nur; };  # <- passing inputs to the attribute set for home-manager
      specialArgs = { inherit system inputs nur; };       # <- passing inputs to the attribute set for NixOS (optional)
    in {
    nixosConfigurations = {
      hp = lib.nixosSystem {
        modules = [
          ./hosts/hp/configuration.nix
          ./hosts/hp/hardware-configuration.nix
	  # NUR module
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
  };
}
