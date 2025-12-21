# Notes: 
(Unfinished?) just for me for now

## Screenshot (12157ef5abcf35a6385a86c2f35c904447df0894)

![Screenshoot of my dotfiles](https://i.postimg.cc/0jF9Rw0H/img-2025-11-25-23-20-32.png)


# Commands to remember for me:
## Update packages and system
```bash
nix flake update
sudo nixos-rebuild switch --flake .#hp
```
## Waydroid-Script (Install things like libndk)
```bash
sudo waydroid-script
```
## Open Waydroid with Xtmapper
```bash
cage_xtmapper.sh
```
## Fix to run project zomboid with libPZXInitThreads64.so 
```
LD_LIBRARY_PATH=$(pwd):\
$(pwd)/linux64:/ \
JAVA_HOME=$(pwd)/jre64 \
PATH=$JAVA_HOME/bin:$PATH \
./ProjectZomboid64
```
## Setup Cloudflare Warp with wgcf and wireguard
```
wgcf register
wgcf generate 
sudo mkdir /etc/wireguard/
sudo cp ./wgcf-profile.conf /etc/wireguard/

```
## Turn Cloudflare Warp on and off 
```
sudo wg-quick up wgcf-profile # To enable
sudo wg-quick down wgcf-profile # To disable
wgcf trace # To test if working find "warp=on"
```
## Vimium C 
useful keybind will make you able to press clickable buttons on a website and make you able to scroll on their
area without activating the button
```
map af LinkHints.activateFocus
```

## How to stop 'git push' asking for username and password token everytime:

First, generate a key, this will be added to https://github.com/settings/ssh/new 
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

## Starts the ssh-agent and the needed environment variables in current terminal
## This is needed to run the next command
```
eval "$(ssh-agent -s)"
```
## ssh-add adds your ssh key to the ssh agent 
```
ssh-add ~/.ssh/id_ed25519
```
## Paste this on github website ssh key
```
cat ~/.ssh/id_ed25519.pub | wl-copy 
```

# Installation (from a already instead system):
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

# My current install method (minimal ISO):

Formatting
```bash
cfdisk # Do what you want, resize, create, partitions
```
```bash
lsblk
```
```bash
mkfs.fat -F 32 /dev/<boot-partition>
```
```bash
mkfs.ext4 /dev/<root-partition>
```
```bash
mkswap /dev/<swap-partition>
```

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
```bash
swapon /dev/swap-partition>
```
Get git
```bash
nix-shell -p git neovim
```
Clone repo
```bash
git clone https://github.com/Mrn157/nix-dotfiles.git
```
Find and replace my hardware-configuration.nix
```bash
sudo nixos-generate-config --root /mnt
```
then
```bash
mv /mnt/etc/nixos/hardware-configuration.nix /home/nixos/nix-dotfiles/hosts/hp/
rm -rf /mnt//etc/nixos/*
```
Somehow the kernel tries to compile instead of using my cache. Temporarily remove this line for now on `configuration.nix`
```bash
kernelPackages = pkgs.linuxPackages_cachyos.cachyOverride { mArch = "GENERIC_V3"; };
```
In order to use the cachyos kernel, Rebuild the system after installing with the line re-added. 
This won't compile the kernel (Last time I tried).

Install
```bash
# go to main dir
cd ~/nix-dotfiles
nixos-install --flake .#hp
```
I then give my user a password
```bash
nixos-enter
passwd mrn1
exit
```

You can now exit the installation ISO and boot

# WARNING! MIGHT BE USED IN THE FUTURE

On `configuration.nix`, I have
```bash
extraModulePackages = with config.boot.kernelPackages; [
    rtw88
    ];
    blacklistedKernelModules = [
    "rtw88_8821ce"
    ];
```
Either remove or change it
