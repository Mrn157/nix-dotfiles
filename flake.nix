{
  description = "Fully reproducible NixOS + Home Manager dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
    in
    {
      nixosConfigurations = {
        # Replace with your actual hostname
        <hostname> = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/<hostname>/configuration.nix
            ./hosts/<hostname>/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.users.<username> = import ./home/<username>/home.nix;
            }
          ];
        };
      };
    };
}
