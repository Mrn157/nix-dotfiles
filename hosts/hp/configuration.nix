{ config, lib, pkgs, nur, ... }:

let
  # Local derivation example
  cage-xtmapper = pkgs.stdenv.mkDerivation {
    pname = "cage-xtmapper";
    version = "1.0";
    src = ./pkgs/cage-xtmapper/cage-xtmapper-v0.2.0.tar;

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = with pkgs; [
      wayland libdrm libxkbcommon pixman mesa vulkan-loader systemd seatd
      xorg.libxcb xorg.xcbutilrenderutil xorg.xcbutil libGL
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp local/bin/cage_xtmapper $out/bin/
      cp local/bin/cage_xtmapper.sh $out/bin/
      chmod +x $out/bin/*
    '';
  };
in
{
  imports = [
    ./hardware-configuration.nix
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Home Manager options (module is imported via flake.nix)
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hp";
  networking.networkmanager.enable = true;

  time.timeZone = "Pacific/Auckland";

  fileSystems."/run/media/mrn1/data" = {
    device = "/dev/disk/by-uuid/06EE19DCEE19C539";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "gid=100" "umask=0022" ];
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-unwrapped"
    "steam-run"
  ];

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  users.users.mrn1 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ tree ];
  };

  environment.systemPackages = with pkgs; [
    neovim wget foot nemo nwg-look git fastfetch floorp rofi-wayland
    udisks2 udiskie ffmpeg_6-full waybar pulsemixer swaybg vulkan-tools
    brightnessctl grim slurp rose-pine-cursor wl-clipboard viewnior sassc
    rose-pine-hyprcursor fzf gcc zsh blueman btop
# For NUR packages add pkgs. before it 
    pkgs.nur.repos.ataraxiasjel.waydroid-script
    ninja meson plocate gnumake cage-xtmapper mpv 
  ];

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs obs-backgroundremoval obs-pipewire-audio-capture
      obs-vaapi obs-gstreamer obs-vkcapture
    ];
  };

  virtualisation.waydroid.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraPackages = [ pkgs.rose-pine-cursor ];
  };

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

  environment.variables = {
    XCURSOR_THEME = "BreezeX-RoséPine";
    XCURSOR_SIZE = "24";
  };

  programs.hyprland.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = { AutoEnable = true; };
    };
  };

  services.udisks2.enable = true;
  services.flatpak.enable = true;

  system.stateVersion = "25.05";
}
