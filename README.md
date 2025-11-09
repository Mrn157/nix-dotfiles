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
Commands to remember:
Waydroid-Script (Install things like libndk)
```bash
sudo waydroid-script
```
Open Waydroid with Xtmapper
```bash
cage_xtmapper.sh
```
Run project zomboid (change the paths to the correct ones)
```
LD_LIBRARY_PATH=/run/media/mrn1/data/Linux/ProjectZomboid42/projectzomboid/linux64:\
/nix/store/jwlvd2j4bl0wyn48kjbkk6bjbqkcf33l-gcc-14.3.0-lib/lib64:\
/nix/store/2lbv5rbgfwh2gn7n6pzb01p5y4vc683z-libXext-1.3.6/lib:\
/nix/store/ayswhp8g569mhb0gbgxrvqw53hsq59mz-libX11-1.8.12/lib:\
/nix/store/9z70y0jwvpb6ibdr7p5df0yc1y59jmyn-libICE-1.1.2/lib:\
/nix/store/7x3klr2v3jyrb86nn92im3ybaxli0vxd-system-path/lib:$LD_LIBRARY_PATH \
JAVA_HOME="$(pwd)/jre64" \
PATH="$JAVA_HOME/bin:$PATH" \
steam-run ./ProjectZomboid64 # PROJECT ZOMBOID RUNNER
```
