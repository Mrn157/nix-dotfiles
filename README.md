Notes: 
(Unfinished??) just for me for now

Installation:
```bash
git clone https://github.com/Mrn157/nix-dotfiles.git && cd ./nix-dotfiles
```
```bash
sudo nixos-generate-config
```
then copy the hardware-configuration to ./hosts/example/
```bash
sudo nixos-rebuild switch --flake .#hp
```
```bash
sudo nix-collect-garbage -d #optional
```
