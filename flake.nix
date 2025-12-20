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
    
    # CachyNix: Commit is on kernel version Linux 6.18.2-cachyos
    cachynix.url = "git+https://github.com/mrn157/CachyNix?rev=4d00458aad8ca915554e14c7f82735b4021e87e0";

    # Spicetify
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };
  outputs = { nixpkgs, home-manager, nur, nixpkgs-stable, flatpaks, cachynix, ... }@inputs:
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
            cachynix.nixosModules.default

            # Spicetify Module
            inputs.spicetify-nix.nixosModules.default

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
