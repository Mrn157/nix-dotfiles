{
  description = "Fully reproducible NixOS + Home Manager dotfiles";
  inputs = {
  # Plymouth (Kept so I can remember)
  #inputs = {
  #  mac-style-plymouth = {
  #     url = "github:SergioRibera/s4rchiso-plymouth-theme";
  #      inputs.nixpkgs.follows = "nixpkgs";
  #  };

    # NUR (Nix User Repository)
    nur.url = "github:nix-community/NUR";

    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    # Home-Manager UNSTABLE
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NVChad
    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Zen Browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
    inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flatpaks
    flatpaks.url = "github:in-a-dil-emma/declarative-flatpak/latest";
    
    # Chaotic: Commit is on kernel version Linux 6.17.9-cachyos
    chaotic.url = "git+https://github.com/mrn157/nyx?rev=1245387e0b6666494bb19a492aa951bb1455e2d5";
  };
  outputs = { nixpkgs, home-manager, nur, nixpkgs-stable, flatpaks, chaotic, ... }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
      };
      pkgs-stable = import nixpkgs-stable { 
        inherit system; 
        config.permittedInsecurePackages = [ "electron-35.7.5" ];
      };
      lib-stable = nixpkgs-stable.lib;
      extraSpecialArgs = { inherit system inputs nur pkgs; };  # <- passing inputs to the attribute set for home-manager
      specialArgs = { inherit system inputs nur pkgs-stable ; };       # <- passing inputs to the attribute set for NixOS (optional)
    in {
    nixosConfigurations = {
        # hp is hostname
        # To change system to use unstable as default, use hp = lib.unstable.nixosSystem {
        hp = lib.nixosSystem {
          modules = [
            ./hosts/hp/configuration.nix
            ./hosts/hp/hardware-configuration.nix
            
            # Flatpak module
            flatpaks.nixosModules.default
  
            # Chaotic Module
            chaotic.nixosModules.default

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
        hp-dwl = lib-stable.nixosSystem {
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
