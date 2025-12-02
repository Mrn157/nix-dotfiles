## Notes: 
(Unfinished??) just for me for now

## Screenshot (12157ef5abcf35a6385a86c2f35c904447df0894)

![Screenshoot of my dotfiles](https://i.postimg.cc/0jF9Rw0H/img-2025-11-25-23-20-32.png)


## Commands to remember:
Update packages and system
```bash
nix flake update
sudo nixos-rebuild switch --flake .#hp
```
Waydroid-Script (Install things like libndk)
```bash
sudo waydroid-script
```
Open Waydroid with Xtmapper
```bash
cage_xtmapper.sh
```
Fix to run project zomboid with libPZXInitThreads64.so 
```
LD_LIBRARY_PATH=$(pwd):\
$(pwd)/linux64:/ \
JAVA_HOME=$(pwd)/jre64 \
PATH=$JAVA_HOME/bin:$PATH \
./ProjectZomboid64
```
Setup Cloudflare Warp with wgcf and wireguard
```
wgcf register
wgcf generate 
sudo mkdir /etc/wireguard/
sudo cp ./wgcf-profile.conf /etc/wireguard/

```
Turn Cloudflare Warp on and off 
```
sudo wg-quick up wgcf-profile # To enable
sudo wg-quick down wgcf-profile # To disable
wgcf trace # To test if working find "warp=on"
```
Vimium C, useful keybind will make you able to press clickable buttons on a website and make you able to scroll on their
area without activating the button
```
map af LinkHints.activateFocus
```

## Installation (from a already instead system):
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

## Installation from minimal ISO (UNFINISHED MAY HAVE MISSING/ERROR PARTS):

Mounting:
```bash
mount /dev/<root-partition> /mnt
```
```bash
mkdir -p /mnt/boot
```
```bash
mount /dev/<boot-partition> /mnt/boot
```
Get git
```bash
nix-shell -p git
```
Clone repo
```bash
git clone https://github.com/Mrn157/nix-dotfiles.git
```
Find and replace my hardware-configuration.nix, CHANGE THE UUID'S and others
```bash
sudo nixos-generate-config --dir .
```
Get neovim (nix-shell -p neovim)
```bash
mv hardware-configuration.nix nix-dotfiles/hosts/hp/yourhardwareconfiguration.nix
nvim nix-dotfiles/hosts/hp/hardware-configuration.nix
```
:split yourhardwareconfiguration.nix
"i" to type (ESC to go back)
"y" to yank/copy
"ctrl+r" to paste
"ctrl+w > h or j" to change focus
Install
```bash
# go to main dir
cd ~/nix-dotfiles
nixos-install --flake .#hp
```
