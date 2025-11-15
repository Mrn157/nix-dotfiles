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
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
    LogLevel=emerg
  '';
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hp";
  networking.networkmanager.enable = true;

  time.timeZone = "Pacific/Auckland";
  services.timesyncd.enable = true;


  fileSystems."/run/media/mrn1/data" = {
    device = "/dev/disk/by-uuid/06EE19DCEE19C539";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "gid=100" "umask=0022" ];
  };

  nixpkgs.config.allowUnfree = true;

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
    neovim wget foot nemo nwg-look git fastfetch appimage-run floorp rofi-wayland unzip cargo
    udisks2 udiskie ffmpeg_6-full waybar pulsemixer swaybg vulkan-tools kdePackages.kdenlive
    brightnessctl grim slurp rose-pine-cursor wl-clipboard viewnior riseup-vpn openshot-qt 
    rose-pine-hyprcursor fzf gcc zsh blueman gdu protonup-ng palemoon-bin protontricks
    cloudflare-warp
# For NUR packages add pkgs. before it 
    pkgs.nur.repos.ataraxiasjel.waydroid-script
    ninja meson plocate gnumake cage-xtmapper mpv tmux dwl p7zip unrar lutris neovide steam-run xorg.libSM
  ];

  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    fuse3
    glib
    nspr
    pango
    gtk3
    cairo
    cups
    atk
    dbus
    expat
    libgbm
    nss_latest
    alsa-lib
    libxkbcommon
    libGL
    xorg.libSM
    xorg.libICE
    xorg.libxcb
    xorg.libXcomposite
    xorg.libX11
    xorg.libXdamage
    xorg.libXfixes
    xorg.libXext
    xorg.libXrandr
    xorg.libXi
    fontconfig
    freetype
    xorg.libXtst
    xorg.libXrender
  ];



  nixpkgs.overlays = [
    (final: prev: {
      dwl = prev.dwl.overrideAttrs (old: {
        src = ./modules/dwl;  # path to your local dwl folder
        buildInputs = old.buildInputs ++ [ 
        prev.wlroots_0_19
        prev.fcft
        prev.libdrm
        ];
        nativeBuildInputs = old.nativeBuildInputs ++ [ prev.pkg-config ];

        #patches = (old.patches or []) ++ [
        #(prev.fetchpatch {
          #excludes = [ "config.def.h" ];
          #url = "https://codeberg.org/dwl/dwl-patches/raw/branch/main/patches/ipc/ipc.patch";
          #sha256 = "sha256-jB8Bw8LYyiS3SdLE2YTmk1OOQXadCOgGP8r/tBUD3qE=";
         #})
        #];
      });
    })
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

  programs.hyprland.enable = true;

  boot = {
    plymouth = {
      enable = true;
      theme = "nixos-bgrt";
      themePackages = with pkgs; [
      nixos-bgrt-plymouth
      ];
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "plymouth.ignore-serial-consoles"
      "udev.log_priority=0" # set to =3 if you want udev error logs
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;

  };

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
