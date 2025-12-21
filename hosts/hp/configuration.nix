{  config, lib, pkgs, pkgs-stable, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # Alternative way to install cage-xtmapper
    # ./pkgs/cage-xtmapper/woah.nix
  ];

  ####################################################
  ### WARNING: EITHER CHANGE OR REMOVE THESE PARTS ###
  ####################################################

  boot = {
    kernelPackages = pkgs.linuxPackages_cachyos-lto.cachyOverride { mArch = "GENERIC_V3"; };
    extraModulePackages = with config.boot.kernelPackages; [
    rtw88
    ];
    blacklistedKernelModules = [
    "rtw88_8821ce"
    ]; 
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
    loader.systemd-boot.consoleMode = "max";
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable = true;

  };

  # Mount other drive
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

  #######################
  ### PACKAGES / PKGS ###
  #######################

  environment.systemPackages =
  (with pkgs; [
      neovim wget foot nemo-with-extensions nwg-look git fastfetch appimage-run unzip cargo
      udisks2 udiskie ffmpeg_6-full waybar pulsemixer swaybg vulkan-tools kdePackages.kdenlive
      brightnessctl grim slurp rose-pine-cursor wl-clipboard viewnior riseup-vpn
      rose-pine-hyprcursor fzf gcc zsh blueman gdu protonup-ng protontricks
      mission-center xwayland-satellite wev wgcf wireguard-tools unrar cachix
      nix-init zed-editor cemu nixd nil python3 yad eza rofi waydroid-helper
      ninja meson plocate gnumake mpv tmux p7zip lutris neovide steam-run xorg.libSM
      rofimoji
      tray-tui
      prismlauncher
      waydroid
      # gvfs (if you want custom folder icons on nemo + trash folder)

    /*  Call the function which is in cage-xtmapper.nix, give it the current pkgs set as input
        and get back whatever it returns (here it is a derivation)
        Variable. When using pkgs = pkgs; it tells configuration.nix
        that to give it the value of pkgs in configuration.nix to pkgs in cage-xtmapper.nix
        This makes it so xtmapper.nix will read configuration.nix "pkgs" with the same value as
        configuration.nix's "pkgs"
    */
    (pkgs.callPackage ./pkgs/cage-xtmapper/cage-xtmapper.nix {})
    (pkgs.callPackage ./pkgs/zsnow/zsnow.nix {})
    (pkgs.callPackage ./modules/dwl/dwl.nix {})
    (pkgs.callPackage ./pkgs/yambar/yambar-pkg.nix {})
    (pkgs.callPackage ./pkgs/gfn-electron/gfn-electron.nix {})
    # For NUR packages add pkgs.nur.. before it
    pkgs.nur.repos.ataraxiasjel.waydroid-script # cage-xtmapper

  ])

  ++
  
  (with pkgs-stable; [
      cmatrix
  ]);

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-unwrapped"
    "steam-run"
    "unrar"
  ];

  ################
  ### SERVICES ###
  ################
  services = {
    # Auto Login Change mrn1 to your username
    getty.autologinUser = "mrn1";
    # Disable tty messages
    getty.greetingLine = lib.mkForce "";
    getty.helpLine = lib.mkForce "";
    # Disable text tty autologin text
    getty.extraArgs = [ "--skip-login" ];
    gnome.gnome-keyring.enable = lib.mkForce false;
    udisks2.enable = true;
    flatpak = {
      enable = true;
      remotes = {
        "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
      };
      packages = [
          "flathub:app/org.vinegarhq.Sober/x86_64/stable"
          # "flathub:app/org.kde.index//stable"
          # "flathub-beta:app/org.kde.kdenlive/x86_64/stable"
          # ":${./foobar.flatpak}"
          # "flathub:/root/testflatpak.flatpakref"
      ];
      overrides = {
        # note: "global" is a flatpak thing
        # if you ever ran "flatpak override" without specifying a ref you will know
        "global".Context = {
          filesystems = [
              "home"
            ];
          sockets = [
              "!x11"
              "!fallback-x11"
            ];
        };
        "org.vinegarhq.Sober" = {
          /* Environment = {
            "MOZ_ENABLE_WAYLAND" = 1;
          }; */
          Context.sockets = [
              "!wayland"
              "!fallback-x11"
              "x11"
            ];
        };
      };
    };
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
    spicetify =
      let
        spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
      in
      {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
      ];
    };
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
    package = pkgs.obs-studio;
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
  xdg.autostart.enable = lib.mkForce false;

  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
      "https://cache.garnix.io"
      # "https://mrn157.cachix.org/"
    ];
    trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      # "mrn157.cachix.org-1:A3KuzqTH/AeTFpDsu7Fql7KpZBJvFCkfNqxkL2+DZlc="
    ];
  };

  #environment.variables = {
  #  XCURSOR_SIZE  = "22";
  #};

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Home Manager options (module is imported via flake.nix)
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
    LogLevel = "emerg";
  };

  networking.hostName = "hp";
  networking.networkmanager.enable = true;

  # Defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases)
  # created on older NixOS versions.
  system.stateVersion = "25.11";

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

  # Sync time with a NTP server
  services.timesyncd.enable = true;

}








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
