Notes: 
(Unfinished??) just for me for now

## Screenshot (Commit 'a9c244ff6ec9139bd1ab13ff75fe1d1f6ddace3b')

![Screenshoot of my dotfiles](https://i.postimg.cc/05CJ13Mc/Screenshot-from-2025-11-22-22-48-38.png)

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
Commands to remember:
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
