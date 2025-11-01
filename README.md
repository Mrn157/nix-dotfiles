Installation:

git clone https://github.com/Mrn157/nix-dotfiles.git
sudo nixos-generate-config
then copy the hardware-configuration to ./hosts/example/
sudo nixos-rebuild switch --flake .#hp
sudo nix-collect-garbage -d (optional)
