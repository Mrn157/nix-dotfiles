{ config, lib, pkgs, nur, pkgs-unstable, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # Alternative way to install cage-xtmapper
    # ./pkgs/cage-xtmapper/woah.nix
  ];

  ################
  ### PACKAGES ###
  ###############
  
  environment.systemPackages = 
  (with pkgs; [
    neovim wget foot nemo-with-extensions nwg-look git fastfetch appimage-run floorp rofi-wayland unzip cargo
    udisks2 udiskie ffmpeg_6-full waybar pulsemixer swaybg vulkan-tools kdePackages.kdenlive
    brightnessctl grim slurp rose-pine-cursor wl-clipboard viewnior riseup-vpn openshot-qt 
    rose-pine-hyprcursor fzf gcc zsh blueman gdu protonup-ng palemoon-bin protontricks
    mission-center gfn-electron xwayland-satellite wev wgcf wireguard-tools
    nix-init zed-editor cemu
    ninja meson plocate gnumake mpv tmux dwl p7zip unrar lutris neovide steam-run xorg.libSM

    # Call the function which is in cage-xtmapper.nix, give it the current pkgs set as input
    # and get back whatever it returns (here it is a derivation)
    (import ./pkgs/cage-xtmapper/cage-xtmapper.nix { pkgs = pkgs; })
    # For NUR packages add pkgs.nur.. before it 
    pkgs.nur.repos.ataraxiasjel.waydroid-script # cage-xtmapper

  ])
  
  ++

  (with pkgs-unstable; [
  waydroid-helper
  ]);

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-unwrapped"
    "steam-run"
  ];
  
 nixpkgs.config.permittedInsecurePackages = [
   "electron-35.7.5"
 ];

  nixpkgs.overlays = [
    (final: prev: {
      dwl = prev.dwl.overrideAttrs (old: rec {
        version = "ab4cb6e28365cf8754d6d3bdd293c05abfc27e26";
        src = builtins.fetchGit {
          url = "https://codeberg.org/dwl/dwl";
          rev = version;
        };
        buildInputs = old.buildInputs ++ [ 
        prev.wlroots_0_19
        prev.fcft
        prev.libdrm
        ];
        nativeBuildInputs = old.nativeBuildInputs ++ [ prev.pkg-config ];

        patches = (old.patches or []) ++ [
        (prev.fetchpatch {
          excludes = [ "config.def.h" ];
          url = "https://codeberg.org/dwl/dwl-patches/raw/branch/main/patches/bar/bar.patch";
          sha256 = "sha256-EZNorxpiNLa4q70vz4uUAiH6x36N/F5oPQ0iJp3m5Nw=";
         })

        (prev.fetchpatch {
          excludes = [ "config.def.h" ];
          url = "https://codeberg.org/dwl/dwl-patches/raw/branch/main/patches/autostart/autostart.patch";
          sha256 = "sha256-f+41++4R22HYtAwHbaRk05TMKCC8mgspwBuNvnmbQfU=";
         })
        (prev.fetchpatch {
          excludes = [ "config.def.h" ];
          url = "https://codeberg.org/dwl/dwl-patches/raw/branch/main/patches/cursortheme/cursortheme.patch";
          sha256 = "sha256-E544m6ca2lYbjYxyThr3GQEhDqh2SDjryLV/g4X8Rt4=";
         })
        ];
        postPatch = ''
        cp ${./modules/dwl/config.def.h} config.def.h
        '';
      });
    })
  ];


  ################
  ### SERVICES ###
  ################
  services = {
    # Auto Login Change mrn1 to your username
    getty.autologinUser = "mrn1";
    udisks2.enable = true;
    flatpak.enable = true;
    pipewire = {
    enable = true;
    pulse.enable = true;
    };
  };



  ################
  ### PROGRAMS ###
  ###############

  programs = {
    niri.enable = true;
    nix-ld.enable = true;
    nix-ld.libraries = with pkgs; [
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

    obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs obs-backgroundremoval obs-pipewire-audio-capture
      obs-vaapi obs-gstreamer obs-vkcapture
      ];
    };

    steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraPackages = [ pkgs.rose-pine-cursor ];
    };

    hyprland.enable = true;

  };
  #####################
  ### MISCELLANEOUS ###
  #####################
  virtualisation.waydroid.enable = true;

  #environment.variables = {
  #  XCURSOR_SIZE  = "22";
  #};

  # Enable flakes
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

  # Defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases)
  # created on older NixOS versions.
  system.stateVersion = "25.05";

  ################
  ### HARDWARE ###
  ################
  hardware = {
    # BLUETOOTH
    bluetooth = {
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
    # ...
  };
  ############
  ### TIME ###
  ############
  time.timeZone = "Pacific/Auckland";
  services.timesyncd.enable = true;

  ##################
  ### AUTO MOUNT ###
  ##################
  fileSystems."/run/media/mrn1/data" = {
    device = "/dev/disk/by-uuid/06EE19DCEE19C539";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "gid=100" "umask=0022" ];
  };
  #############
  ### USERS ###
  #############
  users.users.mrn1 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ tree ];
  };
}

# KEPT FOR REFERENCE: IF YOU NEED TO USE IT, Move it at the top before the opening attribute set
/*
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
*/

